#!/bin/bash
#######################################################################################################################
# Guacamole main build script
# For Ubuntu / Debian / Raspian
# David Harrop
# April 2023
# Special thanks to MysticRyuujin for much of the guac install outline here
# pls see https://github.com/MysticRyuujin/guac-install for more
#######################################################################################################################

clear

# Pre-seed MySQL install values
if [ "${INSTALL_MYSQL}" = true ]; then
debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PWD}"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PWD}"
fi

# Checking if (any kind of) mysql-client or compatible command installed. This is useful for existing mariadb server
if [ "${INSTALL_MYSQL}" = true ]; then
	MYSQL="default-mysql-server default-mysql-client mysql-common"
	elif [ -x "$( command -v mysql )" ]; then
	MYSQL=""
	else
	MYSQL="default-mysql-client"
fi

# Don't do annoying prompts during apt installs
echo
echo -e "${GREY}Updating base Linux OS from apt..."
export DEBIAN_FRONTEND=noninteractive &>> ${LOG_LOCATION}
sudo apt-get update &>> ${LOG_LOCATION}
sudo apt-get upgrade -y &>> ${LOG_LOCATION}
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
fi

# Install Guacamole build dependencies.
echo
echo -e "${GREY}Installing dependencies required for building Guacamole. This might take a few minutes..."
apt-get -y install ${JPEGTURBO} ${LIBPNG} ufw htop pwgen wget crudini build-essential libcairo2-dev libtool-bin uuid-dev libavcodec-dev libavformat-dev libavutil-dev \
libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libpulse-dev libssl-dev \
libvorbis-dev libwebp-dev ghostscript \
${MYSQL} ${TOMCAT_VERSION} &>> ${LOG_LOCATION}
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
fi

# Download Guacamole Server
echo
echo -e "${GREY}Downloading Guacamole source files..."
wget -q --show-progress -O guacamole-server-${GUAC_VERSION}.tar.gz ${GUAC_SOURCE_LINK}/source/guacamole-server-${GUAC_VERSION}.tar.gz
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed to download guacamole-server-${GUAC_VERSION}.tar.gz" 1>&2
	echo -e "${GUAC_SOURCE_LINK}/source/guacamole-server-${GUAC_VERSION}.tar.gz${GREY}"
	exit 1
	else
	tar -xzf guacamole-server-${GUAC_VERSION}.tar.gz
fi
echo -e "${LGREEN}Downloaded guacamole-server-${GUAC_VERSION}.tar.gz${GREY}"

# Download Guacamole Client
wget -q --show-progress -O guacamole-${GUAC_VERSION}.war ${GUAC_SOURCE_LINK}/binary/guacamole-${GUAC_VERSION}.war
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed to download guacamole-${GUAC_VERSION}.war" 1>&2
	echo -e "${GUAC_SOURCE_LINK}/binary/guacamole-${GUAC_VERSION}.war${GREY}"
	exit 1
fi
echo -e "${LGREEN}Downloaded guacamole-${GUAC_VERSION}.war${GREY}"

# Download Guacamole authentication extensions
wget -q --show-progress -O guacamole-auth-jdbc-${GUAC_VERSION}.tar.gz ${GUAC_SOURCE_LINK}/binary/guacamole-auth-jdbc-${GUAC_VERSION}.tar.gz
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed to download guacamole-auth-jdbc-${GUAC_VERSION}.tar.gz" 1>&2
	echo -e "${GUAC_SOURCE_LINK}/binary/guacamole-auth-jdbc-${GUAC_VERSION}.tar.gz"
	exit 1
	else
	tar -xzf guacamole-auth-jdbc-${GUAC_VERSION}.tar.gz
fi
echo -e "${LGREEN}Downloaded guacamole-auth-jdbc-${GUAC_VERSION}.tar.gz${GREY}"

# Download TOTP extension
if [ "${INSTALL_TOTP}" = true ]; then
	wget -q --show-progress -O guacamole-auth-totp-${GUAC_VERSION}.tar.gz ${GUAC_SOURCE_LINK}/binary/guacamole-auth-totp-${GUAC_VERSION}.tar.gz
	if [ $? -ne 0 ]; then
	echo -e "${RED}Failed to download guacamole-auth-totp-${GUAC_VERSION}.tar.gz" 1>&2
	echo -e "${GUAC_SOURCE_LINK}/binary/guacamole-auth-totp-${GUAC_VERSION}.tar.gz"
	exit 1
	else
	tar -xzf guacamole-auth-totp-${GUAC_VERSION}.tar.gz
	fi
echo -e "${LGREEN}Downloaded guacamole-auth-totp-${GUAC_VERSION}.tar.gz${GREY}"
fi

# Download DUO extension
if [ "${INSTALL_DUO}" = true ]; then
	wget -q --show-progress -O guacamole-auth-duo-${GUAC_VERSION}.tar.gz ${GUAC_SOURCE_LINK}/binary/guacamole-auth-duo-${GUAC_VERSION}.tar.gz
	if [ $? -ne 0 ]; then
	echo -e "${RED}Failed to download guacamole-auth-duo-${GUAC_VERSION}.tar.gz" 1>&2
	echo -e "${GUAC_SOURCE_LINK}/binary/guacamole-auth-duo-${GUAC_VERSION}.tar.gz"
	exit 1
	else
	tar -xzf guacamole-auth-duo-${GUAC_VERSION}.tar.gz
	fi
echo -e "${LGREEN}Downloaded guacamole-auth-duo-${GUAC_VERSION}.tar.gz${GREY}"
fi

# Download LDAP extension
if [ "${INSTALL_LDAP}" = true ]; then
	wget -q --show-progress -O guacamole-auth-ldap-${GUAC_VERSION}.tar.gz ${GUAC_SOURCE_LINK}/binary/guacamole-auth-ldap-${GUAC_VERSION}.tar.gz
	if [ $? -ne 0 ]; then
	echo -e "${RED}Failed to download guacamole-auth-ldap-${GUAC_VERSION}.tar.gz" 1>&2
	echo -e "${GUAC_SOURCE_LINK}/binary/guacamole-auth-ldap-${GUAC_VERSION}.tar.gz"
	exit 1
	else
	tar -xzf guacamole-auth-ldap-${GUAC_VERSION}.tar.gz
	fi
echo -e "${LGREEN}Downloaded guacamole-auth-ldap-${GUAC_VERSION}.tar.gz${GREY}"
fi

# Download MySQL connector/j
wget -q --show-progress -O mysql-connector-java-${MYSQLJCON}.tar.gz https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQLJCON}.tar.gz
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed to download mysql-connector-java-${MYSQLJCON}.tar.gz" 1>&2
	echo -e "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQLJCON}}.tar.gz${GREY}"
	exit 1
	else
	tar -xzf mysql-connector-java-${MYSQLJCON}.tar.gz
fi
echo -e "${LGREEN}Downloaded mysql-connector-java-${MYSQLJCON}.tar.gz${GREY}"

echo
echo -e "${LGREEN}Source download complete.${GREY}"

# Option to pause script here as we might want to make final tweaks to source code just before compiling
#echo -e "${LYELLOW}"
#read -t 15 -p $'Script paused for (optional) tweaking of source before building. Enter to Continue... (Script will auto resume after 15 sec.)\n'
#echo -e "${GREY}"

# Make Guacamole directories
rm -rf /etc/guacamole/lib/
rm -rf /etc/guacamole/extensions/
mkdir -p /etc/guacamole/lib/
mkdir -p /etc/guacamole/extensions/

# Fix for #196 see https://github.com/MysticRyuujin/guac-install/issues/196
mkdir -p /usr/sbin/.config/freerdp
chown daemon:daemon /usr/sbin/.config/freerdp

# Fix for #197 see https://github.com/MysticRyuujin/guac-install/issues/197
mkdir -p /var/guacamole
chown daemon:daemon /var/guacamole

# Make and install guacd (Guacamole-Server)
cd guacamole-server-${GUAC_VERSION}/
echo -e "${GREY}Compiling Guacamole-Server from source with with GCC $( gcc --version | head -n1 | grep -oP '\)\K.*' | awk '{print $1}' )  This might take a minute...${GREY}"

# Fix for warnings see #222 https://github.com/MysticRyuujin/guac-install/issues/222
export CFLAGS="-Wno-error"

# Configure Guacamole Server source
./configure --with-systemd-dir=/etc/systemd/system  &>> ${LOG_LOCATION}
if [ $? -ne 0 ]; then
	echo "Failed to configure guacamole-server"
	echo "Trying again with --enable-allow-freerdp-snapshots"
	./configure --with-systemd-dir=/etc/systemd/system --enable-allow-freerdp-snapshots
	if [ $? -ne 0 ]; then
	echo "Failed to configure guacamole-server - again"
	exit
	fi
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

echo -e "${GREY}Running Make and building the Guacamole-Server application executables..."
make &>> ${LOG_LOCATION}
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

echo -e "${GREY}Installing Guacamole-Server..."
make install &>> ${LOG_LOCATION}
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi
ldconfig

# Move files to correct install locations (guacamole-client & Guacamole authentication extensions)
cd ..
mv -f guacamole-${GUAC_VERSION}.war /etc/guacamole/guacamole.war
mv -f guacamole-auth-jdbc-${GUAC_VERSION}/mysql/guacamole-auth-jdbc-mysql-${GUAC_VERSION}.jar /etc/guacamole/extensions/

# Create a symbolic link for Tomcat
ln -sf /etc/guacamole/guacamole.war /var/lib/${TOMCAT_VERSION}/webapps/

# Move MySQL connector/j files
echo -e "${GREY}Moving mysql-connector-java-${MYSQLJCON}.jar (/etc/guacamole/lib/mysql-connector-java.jar)..."
mv -f mysql-connector-java-${MYSQLJCON}/mysql-connector-java-${MYSQLJCON}.jar /etc/guacamole/lib/mysql-connector-java.jar
echo

# Move TOTP files
if [ "${INSTALL_TOTP}" = true ]; then
	echo -e "${GREY}Moving guacamole-auth-totp-${GUAC_VERSION}.jar (/etc/guacamole/extensions/)..."
	mv -f guacamole-auth-totp-${GUAC_VERSION}/guacamole-auth-totp-${GUAC_VERSION}.jar /etc/guacamole/extensions/
	echo
fi

# Move Duo files
if [ "${INSTALL_DUO}" = true ]; then
	echo -e "${GREY}Moving guacamole-auth-duo-${GUAC_VERSION}.jar (/etc/guacamole/extensions/)..."
	mv -f guacamole-auth-duo-${GUAC_VERSION}/guacamole-auth-duo-${GUAC_VERSION}.jar /etc/guacamole/extensions/
	echo
fi

# Move LDAP files
if [ "${INSTALL_LDAP}" = true ]; then
	echo -e "${GREY}Moving guacamole-auth-ldap-${GUAC_VERSION}.jar (/etc/guacamole/extensions/)..."
	mv -f guacamole-auth-ldap-${GUAC_VERSION}/guacamole-auth-ldap-${GUAC_VERSION}.jar /etc/guacamole/extensions/
	echo
fi

# Configure guacamole.properties file
rm -f /etc/guacamole/guacamole.properties
touch /etc/guacamole/guacamole.properties
echo "mysql-hostname: ${MYSQL_HOST}" >> /etc/guacamole/guacamole.properties
echo "mysql-port: ${MYSQL_PORT}" >> /etc/guacamole/guacamole.properties
echo "mysql-database: ${GUAC_DB}" >> /etc/guacamole/guacamole.properties
echo "mysql-username: ${GUAC_USER}" >> /etc/guacamole/guacamole.properties
echo "mysql-password: ${GUAC_PWD}" >> /etc/guacamole/guacamole.properties

# Output Duo configuration settings into guacamole.properties, but comment them all out for now
if [ "${INSTALL_DUO}" = true ]; then
	echo "# duo-api-hostname: " >> /etc/guacamole/guacamole.properties
	echo "# duo-integration-key: " >> /etc/guacamole/guacamole.properties
	echo "# duo-secret-key: " >> /etc/guacamole/guacamole.properties
	echo "# duo-application-key: " >> /etc/guacamole/guacamole.properties
	echo -e "${YELLOW}Duo is installed, it will need to be configured via guacamole.properties${GREY}"
fi

echo -e "${GREY}Applying branded Guacamole login page and favicons."
# For details on how to brand Guacamole, see https://github.com/Zer0CoolX/guacamole-customize-loginscreen-extension
sudo mv branding.jar /etc/guacamole/extensions
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Restart Tomcat
echo -e "${GREY}Restarting Tomcat service & enable at boot..."
service ${TOMCAT_VERSION} restart
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
fi
# Set Tomcat to start at boot
systemctl enable ${TOMCAT_VERSION}
echo

# Set MySQL password
export MYSQL_PWD=${MYSQL_ROOT_PWD}

# Restart MySQL service
if [ "${INSTALL_MYSQL}" = true ]; then
	echo -e "${GREY}Restarting MySQL service & enable at boot..."
	service mysql restart
fi
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Set MySQl to start at boot
systemctl enable mysql

# Default locations of MySQL config files
for x in /etc/mysql/mariadb.conf.d/50-server.cnf \
	/etc/mysql/mysql.conf.d/mysqld.cnf \
	/etc/mysql/my.cnf \
	; do
	# Check the path exists
if [ -e "${x}" ]; then
	# Does it have the necessary section?
	if grep -q '^\[mysqld\]$' "${x}"; then
	mysqlconfig="${x}"
	break
	fi
fi
done

if [ -z "${mysqlconfig}" ]; then
	echo -e "${GREY}Couldn't detect MySQL config file - you may need to manually enter timezone settings"
	else
	# Is there already a value?
	if grep -q "^default_time_zone[[:space:]]?=" "${mysqlconfig}"; then
	echo -e "MySQL database timezone already defined in ${mysqlconfig}"
	else
	timezone="$( cat /etc/timezone )"
	if [ -z "${timezone}" ]; then
	echo -e "Couldn't find system timezone, using UTC$"
	timezone="UTC"
fi
	echo -e "Setting MySQL database timezone as ${timezone}${GREY}"
	# Fix for https://issues.apache.org/jira/browse/GUACAMOLE-760
	mysql_tzinfo_to_sql /usr/share/zoneinfo 2>/dev/null | mysql -u root -D mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT}
	crudini --set ${mysqlconfig} mysqld default_time_zone "${timezone}"
	# Restart to apply
	service mysql restart
fi
fi
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Create ${GUAC_DB} and grant ${GUAC_USER} permissions to it
# SQL code
GUAC_USERHost="localhost"
if [[ "${MYSQL_HOST}" != "localhost" ]]; then
	GUAC_USERHost="%"
	echo -e "${YELLOW}MySQL Guacamole user is set to accept login from any host, please change this for security reasons if possible.${GREY}"
fi

# Check for ${GUAC_DB} already being there
echo -e "${GREY}Checking MySQL for existing database (${GUAC_DB})"
SQLCODE="
SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${GUAC_DB}';"

# Execute SQL code
MYSQL_RESULT=$( echo ${SQLCODE} | mysql -u root -D information_schema -h ${MYSQL_HOST} -P ${MYSQL_PORT} )
if [[ $MYSQL_RESULT != "" ]]; then
	echo -e "${RED}It appears there is already a MySQL database (${GUAC_DB}) on ${MYSQL_HOST}${GREY}" 1>&2
	echo -e "${RED}Try:    mysql -e 'DROP DATABASE ${GUAC_DB}'${GREY}" 1>&2
	#exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Check for ${GUAC_USER} already being there
echo -e "${GREY}Checking MySQL for existing user (${GUAC_USER})"
SQLCODE="
SELECT COUNT(*) FROM mysql.user WHERE user = '${GUAC_USER}';"

# Execute SQL code
MYSQL_RESULT=$( echo ${SQLCODE} | mysql -u root -D mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} | grep '0' )
if [[ $MYSQL_RESULT == "" ]]; then
	echo -e "${RED}It appears there is already a MySQL user (${GUAC_USER}) on ${MYSQL_HOST}${GREY}" 1>&2
	echo -e "${RED}Try:    mysql -e \"DROP USER '${GUAC_USER}'@'${GUAC_USERHost}'; FLUSH PRIVILEGES;\"${GREY}" 1>&2
	#exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Create database & user, then set permissions
SQLCODE="
DROP DATABASE IF EXISTS ${GUAC_DB};
CREATE DATABASE IF NOT EXISTS ${GUAC_DB};
CREATE USER IF NOT EXISTS '${GUAC_USER}'@'${GUAC_USERHost}' IDENTIFIED BY \"${GUAC_PWD}\";
GRANT SELECT,INSERT,UPDATE,DELETE ON ${GUAC_DB}.* TO '${GUAC_USER}'@'${GUAC_USERHost}';
FLUSH PRIVILEGES;"

# Execute SQL code
echo ${SQLCODE} | mysql -u root -D mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT}

# Add Guacamole schema to newly created database
echo -e "${GREY}Adding database tables..."
cat guacamole-auth-jdbc-${GUAC_VERSION}/mysql/schema/*.sql | mysql -u root -D ${GUAC_DB} -h ${MYSQL_HOST} -P ${MYSQL_PORT}
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Create guacd.conf. This is later changed to 127.0.0.1 during Nginx reverse proxy install.
echo -e "${GREY}Binding guacd to 0.0.0.0 port 4822..."
cat > /etc/guacamole/guacd.conf <<- "EOF"
[server]
bind_host = 0.0.0.0
bind_port = 4822
EOF
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Ensure guacd is started
echo -e "${GREY}Starting guacd service & enable at boot..."
systemctl enable guacd
service guacd stop 2>/dev/null
service guacd start
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Cleanup
echo -e "${GREY}Cleanup install files...${GREY}"
rm -rf guacamole-*
rm -rf mysql-connector-java-*
unset MYSQL_PWD
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Apply Secure MySQL installation settings
if [ "${SECURE_MYSQL}" = true ]; then
echo -e "${GREY}Applying mysql_secure_installation settings...${GREY}"
printf "${MYSQL_ROOT_PWD}\n n\n n\n y\n y\n y\n y\n y\n" | mysql_secure_installation -u root --password="${MYSQL_ROOT_PWD}" &>> ${LOG_LOCATION}
fi
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Done
echo -e ${NC}
