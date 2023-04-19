#!/bin/bash
#######################################################################################################################
# Add TOTP (MFA) support for Guacamole
# For Ubuntu / Debian / Raspian
# David Harrop
# April 2023
#######################################################################################################################

clear

cp extensions/guacamole-auth-totp-1.5.0.jar /etc/guacamole/extensions
chmod 664 /etc/guacamole/extensions/guacamole-auth-totp-1.5.0.jar
systemctl restart tomcat9
systemctl restart guacd
echo
echo "Done!"
