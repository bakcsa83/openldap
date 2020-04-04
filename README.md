# openldap installer
OpenLDAP installer - RFC2307bis

Script that 
- installs OpenLDAP on Debian 10
- configures RFC2307bis schema (and drops nis)
- enables {SSHA} hashing for clear text passwords

## Requirements
The script tested on Debian 10, it probably runs fine also on Ubuntu.
Other than the OS there are no other requirements.

## Installation
Installation can be started with the `./install.sh` command.
Be aware that the scripts removes previously installed slapd packages by running `apt purge slapd` 
and deletes ldap related folders like `/etc/ldap` and `/var/lib/ldap`. If have useful data in those directories
then you first have to make backups.

