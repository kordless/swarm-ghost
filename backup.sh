#!/bin/bash

# should we run?
if [ "$BACKUPS_ENABLED" = false ] ; then
	exit
fi

# MySQL configuration
dbhost=$MYSQL_PORT_3306_TCP_ADDR
dbport=$MYSQL_PORT_3306_TCP_PORT
dbname=$MYSQL_DB_NAME
dbuser=$MYSQL_USERNAME
dbpass=$MSYQL_PASSWORD

# Amazon S3 target bucket
bucket=$S3_BUCKET

# pattern to create subdirectories from date elements,
# e. g. '%Y/%m/%d' or '%Y/%Y-%m-%d'
pathpattern=$PATH_DATEPATTERN

# set date-dependent path element
datepath=`date +"$pathpattern"`

# determine file name
datetime=`date +"%Y-%m-%d_%H-%M"`
filename=$dbname_$datetime.sql

echo "Writing backup No. $count for $dbhost:$dbport/$dbname to s3://$bucket/$datepath/$filename.gz"

mysqldump -h $dbhost -P $dbport -u $dbuser --password="$dbpass" $dbname > $filename

gzip $filename
aws s3 cp $filename.gz s3://$bucket/$datepath/$filename.gz && echo "Backup No. $count finished"
rm $filename.gz

