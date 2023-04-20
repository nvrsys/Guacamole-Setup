#!/bin/bash
#######################################################################################################################
# Add TOTP (MFA) support for Guacamole
# For Ubuntu / Debian / Raspian
# David Harrop
# April 2023
#######################################################################################################################

clear

# Check if user is root or sudo
if ! [ $( id -u ) = 0 ]; then
	echo "Please run this script as sudo or root" 1>&2
	exit 1
fi

GUAC_VERSION="1.5.0"
TOMCAT="tomcat9"

cp extensions/guacamole-auth-totp-${GUAC_VERSION}.jar /etc/guacamole/extensions
chmod 664 /etc/guacamole/extensions/guacamole-auth-totp-${GUAC_VERSION}.jar
systemctl restart ${TOMCAT}
systemctl restart guacd
echo
echo "Done!"
