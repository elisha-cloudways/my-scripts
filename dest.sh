#!/bin/bash
# Updated 13:50 PST 18/01/22
set -e
dest_db=$1
dest_db_pw=$2
# prefix=$3
dbaccess="denied"
tab_prefix=$(head -n1 conf-data.txt);
srcURL=$(tail -n1 conf-data.txt);

get_db(){
        read -p 'DB name(Destination): ' dest_db
}
get_pw(){
        read -p 'DB Password(Destination): ' dest_db_pw
}

echo $(tput setaf 3)P.S. $(tput setaf 7)Reset Permissions to Master User on UI before proceeding$'\n'

# Function to get destination details
get_credentials(){
get_db;
get_pw;
}

# Test MySQL credentials
verify_creds(){
        until [[ $dbaccess = "success" ]]; do
               echo "Verifying MySQL credentials..."
               mysql --user="${dest_db}" --password="${dest_db_pw}" -e exit 2>/dev/null
               dbstatus=`echo $?`
               if [ $dbstatus -ne 0 ]; then
                       #echo -e "Destination MySQL Username [$dest_db]: \c "
                       #read dbuser
                       echo $(tput setaf 1)Failed: $(tput setaf 7)Incorrect database credentials $'\n'
                       get_db;
                       get_pw;
               else
                       dbaccess="success"
                       #echo "Success!"
                       echo $(tput setaf 2)Success: $(tput setaf 7)Database credentials verified $'\n'
               fi
       done
}

# Check if db details are provided when running the script
if [ -z $dest_db ] && [ -z $dest_db_pw ]; then
        get_credentials;
        verify_creds;
else
        verify_creds;      
fi

wp config set DB_NAME $dest_db
wp config set DB_USER $dest_db
wp config set DB_PASSWORD $dest_db_pw
wp config set table_prefix $tab_prefix
wp config set DB_HOST localhost
wp config set FS_METHOD direct

wp config list

# Reset Database
echo $'\n'Resetting existing database...
wp db reset --yes

# Import source DB
echo $'\n'Importing source MySQL file...
wp db import $dest_db.sql

destURL="https://$(cat /home/master/applications/$dest_db/conf/server.apache  | grep ServerName |  awk '{print $2}')"

# Fetch Source Domain if empty
if [ -z "$srcURL" ]
then
        read -p "Enter site domain: " srcURL;
else
        # Print out source and destination URLs before search-replace
        echo $(tput setaf 3) $'\n'Source = $(tput setaf 7)$srcURL $'\n'$(tput setaf 3)Destination = $(tput setaf 7)$destURL
fi
# Search-replace dry run
echo $'\n'Search and replace dry run...
wp search-replace "$srcURL" "https://$destURL" --all-tables --dry-run

get_destURL() {
       read -p 'Enter Destination URL: ' destURL
       #echo "$name"
}
get_srcURL() {
       read -p 'Enter Source URL: ' srcURL
       #echo "$name"
}

confirmation(){
        echo $(tput setaf 3)$'\n'Source = $(tput setaf 7)$srcURL $'\n'$(tput setaf 3)Destination = $(tput setaf 7)$destURL$'\n'Do you wish to $(tput setaf 1)proceed$(tput setaf 7)?;
        PS3='Please enter your choice: '
        options=("Yes" "Re-enter Source URL" "Re-enter Destination URL")
        select opt in "${options[@]}"
        do
        case $opt in
        "Yes")
                break
                ;;
        "Re-enter Source URL")
                get_srcURL;
                confirmation;  
                break
                ;;
        "Re-enter Destination URL")
                get_destURL;
                confirmation;  
                break
                ;;
        *) echo $(tput setaf 1)Invalid option $(tput setaf 7)$REPLY;;
    esac
done
}

confirmation;
echo $'\n'Running search and replace...
wp search-replace "$srcURL" "$destURL" --all-tables
echo "$(tput setaf 2)Success: $(tput setaf 7)WP Search and Replace complete."

echo $'\n'Removing WP cache...
wp cache flush
echo "$(tput setaf 7)Removing cache content in wp-content/cache..."
rm -rf /home/master/applications/$db/public_html/wp-content/cache/*
rm -rf ./conf-data.txt
rm -rf ./src.sh
rm -rf ./dest.sh
rm -rf ./$dest_db.sql

echo "$(tput setaf 2)Success: $(tput setaf 7)Cache deleted in wp-content/cache."
echo "Proceed with migration checks. Adios!"
exit;
