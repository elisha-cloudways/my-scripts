#!/bin/bash
db=$1
user=$2
ip=$3
#ssh -i platformops platformops@$ip -p 22

wp db export --no-create-db=true $db.sql

rsync -avuz --progress ../public_html/  $user@$ip://home/master/applications/$db/public_html
