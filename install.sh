
#!/bin/bash
#set -x

LDAP_ETC_DIR="/etc/ldap/"
LDAP_CONF_DIR="/etc/ldap/slapd.d/"
LDAP_DATA_DIR="/var/lib/ldap/"

if [ -d "$LDAP_ETC_DIR" ] || [ -d "$LDAP_DATA_DIR" ]; then
  echo "WARNING! OpenLDAP seems to be installed. Existing configuration and database will be dropped."
  read -p "Do you want to continue? [y/n] : " ANSWER

  if [ "$ANSWER" == "y" ]; then
    apt purge slapd -y
    rm -rf $LDAP_CONF_DIR
    rm -rf $LDAP_DATA_DIR
  else
    echo "exit"
    exit
  fi
fi

echo ""
read -p "Enter domain name (olcSuffix) (e.g.: example.com) : " OLC_SUFFIX_STR
read -p "Enter organisation name (e.g.: Example organisation) : " ORGANISATION

read -s -p "Enter admin password: " ADMIN_PWD
echo ""
read -s -p "Repeat admin password: " ADMIN_PWD2
echo ""

if [ "$ADMIN_PWD" != "$ADMIN_PWD2" ]; then
  echo "Passwords are not the same"
  echo "Exit"
  exit
fi

sed 's/VAR_OLC_SUFFIX/'"$OLC_SUFFIX_STR"'/g; s/VAR_ORGANIZATION/'"$ORGANISATION"'/g; s/VAR_ADMIN_PWD/'"$ADMIN_PWD"'/g' slpad_inst.conf > slpad_inst.conf.cust
export DEBIAN_FRONTEND=noninteractive
cat slpad_inst.conf.cust | debconf-set-selections
apt update
echo ""
echo "Installing OpenLdap"
apt install ldap-utils slapd -y


OLC_SUFFIX=""
OLDIFS=$IFS
export IFS="."
for i in $OLC_SUFFIX_STR; do
  if [ -z "$OLC_SUFFIX" ]; then
    OLC_SUFFIX="dc=$i"
  else
    OLC_SUFFIX="$OLC_SUFFIX,dc=$i"
  fi
done
export IFS="$OLDIFS"

sed 's/dc=example,dc=org/'$OLC_SUFFIX'/g' config.ldif > config.ldif.cust
service slapd stop

echo "Delete old config"
rm -rf $LDAP_CONF_DIR*

echo "Apply config with rfc2307bis schema"
slapadd -F "$LDAP_CONF_DIR" -n 0 -l config.ldif.cust
chown -R openldap:openldap $LDAP_CONF_DIR
service slapd start

rm config.ldif.cust
rm slpad_inst.conf.cust

##
# Member of overlay related instructions are from https://tylersguides.com/guides/openldap-memberof-overlay/
ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f load_memberof.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f apply_memberof.ldif

##
# Enable password hashing
ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/ppolicy.ldif
ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f load_ppolicy.ldif
ldapadd -Q -Y EXTERNAL -H ldapi:/// -f apply_ppolicy.ldif

echo "Done"
