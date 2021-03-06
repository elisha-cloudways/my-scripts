#!/bin/bash
# Updated 10:06 PST 20/02/22
set -e

dest_db=$1
ssh_user=$2
dest_ip=$3
path=$4

# Fetch Source database details
srcdb=$(sed -n "s/define( *'DB_NAME', *'\([^']*\)'.*/\1/p" wp-config.php)
srcusr=$(sed -n "s/define( *'DB_USER', *'\([^']*\)'.*/\1/p" wp-config.php)
srcpwd=$(sed -n "s/define( *'DB_PASSWORD', *'\([^']*\)'.*/\1/p" wp-config.php)
webroot=$(pwd)/

get_db(){
        read -p 'DB name(Destination): ' dest_db
}
get_user(){
        read -p 'Master User(Destination): ' ssh_user
}
get_ip(){
        read -p 'Server IP(Destination): ' dest_ip
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
        if ssh $ssh_user@$dest_ip [ -d /home/master/applications/$dest_db/public_html ];
        then
                echo $(tput setaf 2)$'\n'Success: $(tput setaf 7)SSH credentials verified$'\n'
        else
                echo $(tput setaf 1)$'\n'Failed: $(tput setaf 7)Credentials are incorrect. Connection failed$'\n'
        get_credentials;
        verify_creds;
fi
}

# Check if variables are provided when running the script
if [ -z $dest_db ] && [ -z $ssh_user ] && [ -z $dest_ip ]; then
        get_credentials;
        verify_creds;
else
        verify_creds;
fi

# Move files to the Cloudways server 
rsync_files(){
if [ -z "$path" ]
then
        echo $'\n'Transferring files...
        rsync -avuz --progress $webroot $ssh_user@$dest_ip://home/master/applications/$dest_db/public_html
else
        echo $'\n'Transferring files...
        rsync -avuz --progress $path $ssh_user@$dest_ip://home/master/applications/$dest_db/public_html
fi
}
rsync_files;

rm -rf ./sync.sh
exit;
