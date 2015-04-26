#!/bin/bash
GHOST="/ghost"
OVERRIDE="/ghost-override"

# config files
CONFIG="config.js"
CONFIG_NOMAIL="$OVERRIDE/config_nomail.js"
CONFIG_MAILGUN="$OVERRIDE/config_mailgun.js"

# backup script
BACKUP_SCRIPT="backup.sh"

# ghost content directories
DATA="content/data"
IMAGES="content/images"
THEMES="content/themes"

# db backup file
DB_BACKUP="$OVERRIDE/blog.sql"

# switch to ghost directory
cd "$GHOST"

# Symlink data directory.
mkdir -p "$OVERRIDE/$DATA"
rm -fr "$DATA"
ln -s "$OVERRIDE/$DATA" "content"

# Symlink images directory
mkdir -p "$OVERRIDE/$IMAGES"
rm -fr "$IMAGES"
ln -s "$OVERRIDE/$IMAGES" "$IMAGES"

echo "##############################################################"

# toggle on mail configuration
if [[ -z "$MAILGUN_USERNAME" ]]; then
  cp $CONFIG_NOMAIL $OVERRIDE/$CONFIG
  echo "Using stock mail configuration..."
else
  cp $CONFIG_MAILGUN $OVERRIDE/$CONFIG
  echo "Using Mailgun configuration..."
fi

# Symlink config file.
if [[ -f "$OVERRIDE/$CONFIG" ]]; then
  echo "Using $OVERRIDE/$CONFIG for config file."
  rm -f "$CONFIG"
  ln -s "$OVERRIDE/$CONFIG" "$CONFIG"
fi

# Symlink themes.
if [[ -d "$OVERRIDE/$THEMES" ]]; then
  echo "Using $OVERRIDE/$THEMES for theme directory."
  for theme in $(find "$OVERRIDE/$THEMES" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
  do
    rm -fr "$THEMES/$theme"
    ln -s "$OVERRIDE/$THEMES/$theme" "$THEMES/$theme"
  done
fi

echo "##############################################################"

# patch the config file
echo "Patching ghost config file..."
sed -e "s,%HOSTNAME%,$HOSTNAME,g;" -i $CONFIG
sed -e "s,%CNAME%,$CNAME,g;" -i $CONFIG
sed -e "s,%MYSQL_SERVER%,$MYSQL_PORT_3306_TCP_ADDR,g;" -i $CONFIG
sed -e "s,%MYSQL_USERNAME%,$MYSQL_USERNAME,g;" -i $CONFIG
sed -e "s,%MYSQL_PASSWORD%,$MYSQL_PASSWORD,g;" -i $CONFIG
sed -e "s,%MYSQL_DATABASE%,$MYSQL_DATABASE,g;" -i $CONFIG
sed -e "s,%MAILGUN_USERNAME%,$MAILGUN_USERNAME,g;" -i $CONFIG
sed -e "s,%MAILGUN_APIKEY%,$MAILGUN_APIKEY,g;" -i $CONFIG

# patch the backup file
echo "Patching backup file..."
sed -e "s,%MYSQL_PORT_3306_TCP_ADDR%,$MYSQL_PORT_3306_TCP_ADDR,g;" -i $BACKUP_SCRIPT
sed -e "s,%MYSQL_PORT_3306_TCP_PORT%,$MYSQL_PORT_3306_TCP_PORT,g;" -i $BACKUP_SCRIPT
sed -e "s,%MYSQL_DATABASE%,$MYSQL_DATABASE,g;" -i $BACKUP_SCRIPT
sed -e "s,%MYSQL_USERNAME%,$MYSQL_USERNAME,g;" -i $BACKUP_SCRIPT
sed -e "s,%MSYQL_PASSWORD%,$MYSQL_PASSWORD,g;" -i $BACKUP_SCRIPT

sed -e "s,%S3_BUCKET%,$S3_BUCKET,g;" -i $BACKUP_SCRIPT
sed -e "s,%AWS_ACCESS_KEY_ID%,$AWS_ACCESS_KEY_ID,g;" -i $BACKUP_SCRIPT
sed -e "s,%AWS_SECRET_ACCESS_KEY%,$AWS_SECRET_ACCESS_KEY,g;" -i $BACKUP_SCRIPT
sed -e "s,%AWS_DEFAULT_REGION%,$AWS_DEFAULT_REGION,g;" -i $BACKUP_SCRIPT

# if we have a mysql backup, push it
if [[ -f "$DB_BACKUP" ]]; then
  echo "Found database backup. Extracting and pushing to configured database."
  mysql -h $MYSQL_PORT_3306_TCP_ADDR -u $MYSQL_USERNAME -p$MYSQL_PASSWORD $MYSQL_DATABASE < $DB_BACKUP
fi

# handle cron backups, if enabled
if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
  echo "Backups are disabled..."
else
  # install crontab file and start cron
  echo "Installing backup script and starting cron..."
  /usr/bin/crontab /ghost/cron.conf
  /usr/sbin/cron
fi

# start ghost
chown -R ghost:ghost /data /ghost /ghost-override
su ghost << EOF
cd "$GHOST"
NODE_ENV=${NODE_ENV:-production} npm start
EOF
