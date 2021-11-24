#!/bin/bash
db=$1
user=$2
ip=$3
path=$4
echo $(wp config get table_prefix) > prefix.txt
webroot=$(pwd)/

echo $'\n'Exporting database...
wp db export --no-create-db=true $db.sql

if [ -z "$path" ]
then
        rsync -avuz --progress $webroot $user@$ip://home/master/applications/$db/public_html

else
        rsync -avuz --progress $path $user@$ip://home/master/applications/$db/public_html
fi
