#!/bin/bash
#######################################################################################################################
# Add Active Directory integration with Guacamole
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
	echo
	echo -e "${LGREEN}Please run this script as sudo or root${NC}" 1>&2
	exit 1
fi

GUAC_VERSION="1.5.0"
TOMCAT="tomcat9"
GUAC_SOURCE_LINK="http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VERSION}"
echo
echo -e "${YELLOW}Have you updated this script to reflect your Active Directory settings?${NC}"

read -p "Do you want to proceed? (yes/no) " yn
case $yn in 
	y ) echo Beginning LDAP auth config...;;
	n ) echo exiting...;
		exit;;
	* ) echo invalid response;
		exit 1;;
esac

echo
wget -q --show-progress -O guacamole-auth-ldap-${GUAC_VERSION}.tar.gz ${GUAC_SOURCE_LINK}/binary/guacamole-auth-ldap-${GUAC_VERSION}.tar.gz
tar -xzf guacamole-auth-ldap-${GUAC_VERSION}.tar.gz
echo
echo Adding the below config to /etc/guacamole/guacamole.properties 
cat <<EOF | sudo tee -a /etc/guacamole/guacamole.properties
ldap-hostname: dc1.yourdomain.com dc2.yourdomain.com
ldap-port: 389
ldap-username-attribute: sAMAccountName
ldap-encryption-method: none
ldap-search-bind-dn: ad-account@yourdomain.com
ldap-search-bind-password: ad-account-password
ldap-config-base-dn: dc=domain,dc=com
ldap-user-base-dn: OU=SomeOU,DC=domain,DC=com
ldap-user-search-filter:(objectClass=user)(!(objectCategory=computer))
ldap-max-search-results:200
EOF

mv -f guacamole-auth-ldap-${GUAC_VERSION}/guacamole-auth-ldap-${GUAC_VERSION}.jar /etc/guacamole/extensions/
sudo chmod 664 /etc/guacamole/extensions/guacamole-auth-ldap-${GUAC_VERSION}.jar
sudo systemctl restart ${TOMCAT}
sudo systemctl restart guacd

rm -xzf guacamole-auth-ldap-${GUAC_VERSION}.tar.gz

echo
echo "Done!"
echo -e ${NC}