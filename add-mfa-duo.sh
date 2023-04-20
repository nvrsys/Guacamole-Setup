#!/bin/bash
#######################################################################################################################
# Add Duo (MFA) support to Guacamole
# For Ubuntu / Debian / Raspian
# David Harrop
# April 2023
#######################################################################################################################

# Prepare text output colours
GREY='\033[0;37m'
DGREY='\033[0;90m'
GREYB='\033[1;37m'
RED='\033[0;31m'
LRED='\033[0;91m'
GREEN='\033[0;32m'
LGREEN='\033[0;92m'
YELLOW='\033[0;33m'
LYELLOW='\033[0;93m'
BLUE='\033[0;34m'
LBLUE='\033[0;94m'
CYAN='\033[0;36m'
LCYAN='\033[0;96m'
MAGENTA='\033[0;35m'
LMAGENTA='\033[0;95m'
NC='\033[0m' #No Colour

clear

# Check if user is root or sudo
if ! [ $( id -u ) = 0 ]; then
	echo -e "${LGREEN}Please run this script as sudo or root${NC}" 1>&2
	exit 1
fi

GUAC_VERSION="1.5.0"
TOMCAT="tomcat9"

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
