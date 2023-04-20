#!/bin/bash
#######################################################################################################################
# Add Duo (MFA) support to Guacamole
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

cp extensions/guacamole-auth-duo-${GUAC_VERSION}.jar /etc/guacamole/extensions
chmod 664 /etc/guacamole/extensions/guacamole-auth-duo-${GUAC_VERSION}.jar
echo "# duo-integration-key: " >> /etc/guacamole/guacamole.properties
echo "# duo-secret-key: " >> /etc/guacamole/guacamole.properties
echo "# duo-api-hostname: " >> /etc/guacamole/guacamole.properties
echo "# duo-application-key: " >> /etc/guacamole/guacamole.properties

systemctl restart ${TOMCAT}
sudo systemctl restart guacd

echo "Done. You must now set up your online Duo account with a new 'Web SDK' application."
echo
echo "Copy the approriate API settings from your Duo account into /etc/guacamole/guacamole.properties in the below format."
echo "Be VERY careful to avoid extra spaces or characters when pasting!"
echo
echo "duo-integration-key: ??????????"
echo "duo-api-hostname: ??????????"
echo "duo-secret-key: ??????????"
echo "duo-application-key: (this is locally created - run 'pwgen 40 1' to manually generate this 40 char random value)"
echo
echo "Then restart Guacamole with sudo systemctl restart tomcat9"
echo
echo "Done!"
