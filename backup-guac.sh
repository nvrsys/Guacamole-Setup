#!/bin/bash
#######################################################################################################################
# Guacamole MySQL Database Backup
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

if ! [ $( id -u ) = 0 ]; then
	echo
	echo -e "${LGREEN}Please run this script as sudo or root${NC}" 1>&2
	exit 1
fi

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +%Y-%m-%d`
USER_HOME_DIR=$(eval echo ~${SUDO_USER})

# Update below values
DB_BACKUP_PATH=$USER_HOME_DIR/mysqlbackups/
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER='root'
MYSQL_PASSWORD='yourpassword'
DATABASE_NAME='guacamole_db'
BACKUP_RETAIN_DAYS=30 ## Number of days to keep local backup copy
RECIPIENT_EMAIL=yourname@gmail.com

# Backup code
mkdir -p ${DB_BACKUP_PATH}
echo "Backup started for database - ${DATABASE_NAME}"

mysqldump -h ${MYSQL_HOST} \
-P ${MYSQL_PORT} \
-u ${MYSQL_USER} \
-p${MYSQL_PASSWORD} \
${DATABASE_NAME} \
 --single-transaction --quick --lock-tables=false > \
${DB_BACKUP_PATH}${DATABASE_NAME}-${TODAY}.sql 
SQLFILE=${DB_BACKUP_PATH}${DATABASE_NAME}-${TODAY}.sql
gzip -f ${SQLFILE} 

# Error check and email alerts
if [ $? -eq 0 ]; then
echo "Guacamomle Database Backup Success" | mailx -s "Guacamomle Database Backup Success" ${RECIPIENT_EMAIL}
else
echo "Guacamomle Database Backup Failed" | mailx -s "Guacamomle Database Backup failed" ${RECIPIENT_EMAIL}
exit 1
fi

# Protect disk space and remove backups older than {BACKUP_RETAIN_DAYS} days
find ${DB_BACKUP_PATH} -mtime +${BACKUP_RETAIN_DAYS} -delete

echo
echo "Done!"
echo -e ${NC}