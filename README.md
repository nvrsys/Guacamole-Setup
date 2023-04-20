# Guacamole 1.5.0 RDP jump server appliance with MFA, Active Directory integration & Nginx SSL reverse proxy

## Prerequisites:

	Ubuntu  / Debian / Raspian
 	Min 8GB RAM, 40GB HDD
	Public or private DNS entries matching the default physical interface IP address. (needed for SSL) 
	Incoming access on tcp 22, 80 & 443


## Automatic build, install & config script:

    wget https://raw.githubusercontent.com/itiligent/Guacamole-Setup/main/1-setup.sh && chmod +x 1-setup.sh && ./1-setup.sh

## 2. Follow on screen prompts to install Guacamole.

	Install menu options are:
	
	1. Install default Guacamole with either a local MySQL database or with a remote MySQL instance 
	
		a. Add Guacamole MFA and Auth extensions (DUO, TOTP, LDAP)
		b. Add MySQL mysql_secure_installation settings 
	
	2. Optionally add a reverse proxy front end to Guacamole of either..
			
		a) None: Skip Nginx and keep the default Guacamole front end e.g. http://hostname:8080/guacamole
		b) Install Nginx with NO SSL (http 80) e.g. http://hostname.local
		c) Install Nginx with SELF SIGNED SSL certificates e.g. https://hostname.local
			(includes client certificates for Windows & Linux browsers with final SSL client setup instructions.
		d) Install Nginx with LET'S ENCRYPT certificates e.g. https://public.site.com
	
				
	Items downloaded are setup are placed in the $DOWNLOAD_DIR/guacamole-setup dir as follows
	1. 1-setup.sh				- the parent install script itself
	2. 2-install-guacamole.sh 		- Guacamole install script (inspired by https://github.com/MysticRyuujin/guac-install)
	3. 3-install-nginx.sh 			- Installs Nginx and auto configures as a front end for Guacamole (optional)
	4. 4a-install-ssl-self-signed-nginx.sh 	- Configures self signed ssl certs for Nginx (optional)
	5. 4b-install-ssl-letsencrypt-nginx.sh 	- Installs and configures Let's Encrypt with Guacamole and Nginx (optional)
	6. add-duo-mfa-guacamole.sh 		- Adds the Duo MFA extensions to Guacamole if not selected at install (optional)
	7. add-ldap-auth-guacamole.sh 		- Adds the LDAP Active Directory extension to Guacamole and guides the specific LDAP setup requirements (optional)
	8. add-totp-mfa-guacamole.sh  		- Adds the TOTP MFA extension to Guacamole if not selected at install (optional)
	9. add-ssl-guac-to-gaucd.sh 		- A hardening script to wrap an extra ssl layer between the guacd server and the Guacamole client (optional)
	10. add-fail2ban.sh			- Adds and configures fail2ban to secure Guacamole against brute force attacks
	11. backup-guacamole.sh			- A simple Guacamole backup script
	12. branding.jar			- An extension to customise the Guacomole login screen (optional) 
	  					 see: https://github.com/Zer0CoolX/guacamole-customize-loginscreen-extension
 
Special thanks to:
MysticRyuujin @ https://github.com/MysticRyuujin/guac-install - This repo has been a very helpful resouce.
	
Zer0CoolX @ https://github.com/Zer0CoolX/guacamole-customize-loginscreen-extension - The login screen extension is entirely borrowed. I have not linked to the original repo version in this case becasue the branding.jar extension included has some additional non default examples applied regarding the handling of logos and browser favicons.
