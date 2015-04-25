#!/bin/bash

# mysql configuration
dbhost=%MYSQL_PORT_3306_TCP_ADDR%
dbport=%MYSQL_PORT_3306_TCP_PORT%
dbname=%MYSQL_DATABASE%
dbuser=%MYSQL_USERNAME%
dbpass=%MSYQL_PASSWORD%

# export aws credentials to env
export AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY_ID%
export AWS_SECRET_ACCESS_KEY=%AWS_SECRET_ACCESS_KEY%
export AWS_DEFAULT_REGION=%AWS_DEFAULT_REGION%
 
# S3 target bucket
bucket=%S3_BUCKET%

# pattern to create subdirectories from date elements,
# e. g. '%Y/%m/%d' or '%Y/%Y-%m-%d'
pathpattern='%Y/%m'

# set date-dependent path element
datepath=`date +"$pathpattern"`

# write out the mysql dump file
datetime=`date +"%Y-%m-%d_%H-%M"`
filename=mysql_$dbname_$datetime.sql
echo "Writing backup for $dbhost:$dbport/$dbname to s3://$bucket/$datepath/$filename.gz"
mysqldump -h $dbhost -P $dbport -u $dbuser --password="$dbpass" $dbname > $filename

# write out the content backup
content_filename=content_images_$datetime.tar.gz
tar cvfz $content_filename /ghost-override/content/images/

# zip and send 'em
gzip $filename
/usr/local/bin/aws s3 cp $filename.gz s3://$bucket/$datepath/$filename.gz && echo "Database backup uploaded."
/usr/local/bin/aws s3 cp $content_filename s3://$bucket/$datepath/$content_filename && echo "Content backup uploaded."
rm $filename.gz
