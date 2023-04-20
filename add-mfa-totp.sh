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

# Find the correct tomcat package (with a little future proofing)
if [[ $( apt-cache show tomcat10 2> /dev/null | egrep "Version: 10" | wc -l ) -gt 0 ]]; then
	TOMCAT="tomcat10"
	elif [[ $( apt-cache show tomcat9 2> /dev/null | egrep "Version: 9" | wc -l ) -gt 0 ]]; then
	TOMCAT="tomcat9"
else
	echo -e "${RED}Failed. Can't find Tomcat package${GREY}" 1>&2
	exit 1
fi

cp extensions/guacamole-auth-totp-${GUAC_VERSION}.jar /etc/guacamole/extensions
chmod 664 /etc/guacamole/extensions/guacamole-auth-totp-${GUAC_VERSION}.jar
systemctl restart ${TOMCAT}
systemctl restart guacd
echo
echo "Done!"
