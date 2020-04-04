# openldap installer
OpenLDAP installer - RFC2307bis

Script that 
- installs OpenLDAP on Debian 10
- configures RFC2307bis schema (and drops nis)
- enables {SSHA} hashing for clear text passwords
- adds ACL for admins group

## Requirements
The script tested on Debian 10, it probably runs fine also on Ubuntu.
Other than the OS there are no other requirements.

## Installation
Installation can be started with the `./install.sh` command.
Be aware that the scripts removes previously installed slapd packages by running `apt purge slapd` 
and deletes ldap related folders like `/etc/ldap` and `/var/lib/ldap`. If have useful data in those directories
then you first have to make backups.


## Admins group
The config.ldif has an extra ACL:
`olcAccess: {2}to * by group.exact="cn=admins,dc=example,dc=org" manage by * read`
It means that members of the `cn=admins,dc=your,dc=domain` group have full control over the whole tree.
The install script does not create automatically this group though, it has to be done manually.
If you need it just create a new groupOfNames object with the following RDN `cn=admins,dc=your,dc=domain`.
Do not forget to replace dc=your,dc=domain with your own domain name.

## Credit and source
https://tylersguides.com/all-guides/   
https://unix.stackexchange.com/a/363087
https://daenney.github.io/2018/10/27/ldap-writing-testing-acls#structure-of-an-acl
