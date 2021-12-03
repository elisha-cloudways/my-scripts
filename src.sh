#!/bin/bash

db=$1
user=$2
ip=$3
path=$4

# Fetch source table_prefix
sed -n "s/^.*\$table_prefix *= *'\([^']*\)'.*\$/\1/p" wp-config.php > prefix.txt

# Fetch Source database details
srcdb=$(sed -n "s/define( *'DB_NAME', *'\([^']*\)'.*/\1/p" wp-config.php)
srcusr=$(sed -n "s/define( *'DB_USER', *'\([^']*\)'.*/\1/p" wp-config.php)
srcpwd=$(sed -n "s/define( *'DB_PASSWORD', *'\([^']*\)'.*/\1/p" wp-config.php)
webroot=$(pwd)/

get_db(){
        read -p 'DB name(Destination): ' db
}
get_user(){
        read -p 'Master User(Destination): ' user
}
get_ip(){
        read -p 'Server IP(Destination): ' ip
}

echo $(tput setaf 3)P.S. $(tput setaf 7)Reset Permissions to Master User on UI before proceeding$'\n'

# Function to get destination details
get_credentials(){
get_db;
get_user;
get_ip;
}

# Checks if SSH details are correct
verify_creds(){
        if ssh $user@$ip [ -d /home/master/applications/$db/public_html ];
        then
                echo $(tput setaf 2)$'\n'Success: $(tput setaf 7)SSH credentials verified$'\n'
        else
                echo $(tput setaf 1)$'\n'Failed: $(tput setaf 7)Credentials are incorrect. Connection failed$'\n'
        get_credentials;
        verify_creds;
fi
}

# Check if variables are provided when running the script
if [ -z $db ] && [ -z $user ] && [ -z $ip ]; then
        get_credentials;
        else
                verify_creds;
fi
exit;
