#!/bin/bash
db=$1
pw=$2
prefix=$3

wp config set DB_NAME $db
wp config set DB_USER $db
wp config set DB_PASSWORD $pw
wp config set DB_HOST localhost
wp config set FS_METHOD direct

if test -z "$prefix"
then
        echo "WP-config updated successfully"
else
        wp config set table_prefix $prefix
        echo "WP-config updated successfully"
fi

