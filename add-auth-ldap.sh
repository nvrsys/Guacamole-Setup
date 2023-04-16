#!/bin/bash
#########################################################################
# Add Active Directory integration with Guacamole
# For Ubuntu / Debian / Raspian
# David Harrop
# April 2023
#########################################################################
clear

YELLOW='\033[1;33m'
NC='\033[0m'
echo -e "${YELLOW}Have you updated this script to reflect your Active Directory settings?${NC}"

read -p "Do you want to proceed? (yes/no) " yn

case $yn in 
	y ) echo Adding the below config to /etc/guacamole/guacamole.properties ;;
	n ) echo exiting...;
		exit;;
	* ) echo invalid response;
		exit 1;;
esac
echo
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
sudo cp extensions/guacamole-auth-ldap-1.5.0.jar /etc/guacamole/extensions
sudo chmod 664 /etc/guacamole/extensions/guacamole-auth-ldap-1.5.0.jar
sudo systemctl restart tomcat9
sudo systemctl restart guacd
echo
echo "Done!"
# Done
echo -e ${NC}
