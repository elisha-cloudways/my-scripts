#!/bin/bash
db=$1
user=$2
ip=$3
path=$4

wp db export --no-create-db=true $db.sql

if [ -z "$path" ]
then
        rsync -avuz --progress ../public_html/  $user@$ip://home/master/applications/$db/public_html

else
        rsync -avuz --progress $path $user@$ip://home/master/applications/$db/public_html
fi
