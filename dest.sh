#!/bin/bash
db=$1
pw=$2
# prefix=$3
tab_prefix=$(<prefix.txt);

wp config set DB_NAME $db
wp config set DB_USER $db
wp config set DB_PASSWORD $pw
wp config set table_prefix $tab_prefix
wp config set DB_HOST localhost
wp config set FS_METHOD direct

#if test -z "$prefix"
#then
#        echo $'\n'$(tput setaf 2)Success: $(tput setaf 7)WP-config updated successfully$(tput setaf 7) $'\n'
#        else
#                wp config set table_prefix $prefix
#                echo $'\n'$(tput setaf 2)Success: $(tput setaf 7)WP-config updated successfully$(tput setaf 7) $'\n'
#        fi

wp config list

# Reset Database
echo $'\n'Resetting existing database...
wp db reset --yes

# Import source DB
echo $'\n'Importing source MySQL file...
wp db import $db.sql

#echo $(tput setaf 2)Database has been imported$'\n'
# Fetch Source Domain
srcURL=$(wp db query 'SELECT * FROM wp_options WHERE option_name="siteurl"' --skip-column-names | awk '{print $3}')

destURL="https://$(cat /home/master/applications/$db/conf/server.apache  | grep ServerName |  awk '{print $2}')"

# Print out source and destination URLs before search-replace
echo $(tput setaf 7) $'\n'Source = $(tput setaf 3)$srcURL $'\n'$(tput setaf 7)Destination = $(tput setaf 3)$destURL $(tput setaf 7)
#exit;

# Search-replace dry run
echo $'\n'Search and replace dry run...
wp search-replace "$srcURL" "https://$destURL" --all-tables --dry-run

get_destURL() {
       read -p 'Enter Destination URL: ' destURL
       #echo "$name"
}
confirmation(){
        #echo "Do you wish to proceed?" \ && echo "Source = $srcURL" \ && echo "Destination = $destURL"\ && echo "Enter (1,2,3):"
        #echo $(tput setaf 7)$'\n'Source = $(tput setaf 3)$srcURL $'\n'$(tput setaf 7)Destination = $(tput setaf 3)$destURL $'\n'Do you wish to proceed? Enter (1,2 or 3):$'\n' 
        echo $(tput setaf 7)$'\n'Source = $(tput setaf 3)$srcURL $'\n'$(tput setaf 7)Destination = $(tput setaf 3)$destURL $'\n'$(tput setaf 7)$'\n'Do you wish to $(tput setaf 1)proceed$(tput setaf 7)? "Enter (1,2 or 3):"
        select yn in "Yes" "No" "Re-enter Destination URL"; do
        case $yn in
                Yes ) break;;
                No ) echo $'\n'$(tput setaf 1)Exiting...$(tput setaf 7); exit;;
                "Re-enter Destination URL" ) get_destURL; confirmation;;
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

echo "$(tput setaf 2)Success: $(tput setaf 7)Cache deleted in wp-content/cache."
echo "Proceed with migration checks. Adios!"
exit;
