#!/bin/bash
#######################################################################################################################
# Add TOTP (MFA) support for Guacamole
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
GUAC_SOURCE_LINK="http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VERSION}"

echo
wget -q --show-progress -O guacamole-auth-totp-${GUAC_VERSION}.tar.gz ${GUAC_SOURCE_LINK}/binary/guacamole-auth-totp-${GUAC_VERSION}.tar.gz
echo
mv guacamole-auth-totp-${GUAC_VERSION}.jar /etc/guacamole/extensions
chmod 664 /etc/guacamole/extensions/guacamole-auth-totp-${GUAC_VERSION}.jar
systemctl restart ${TOMCAT}
systemctl restart guacd
echo
echo "Done!"
