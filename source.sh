#!/bin/bash
# Updated 11:50 PST 18/01/22
path=$1
echo $(wp config get table_prefix) > prefix.txt
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

get_credentials(){
        get_db;
        get_user;
        get_ip;
        if ssh $user@$ip [ -d /home/master/applications/$db/public_html ];
        then
                echo $(tput setaf 2)Success: $(tput setaf 7)SSH credentials verified$'\n'
                #break;
        else
                echo $(tput setaf 1)Failed: $(tput setaf 7)Credentials are incorrect. Connection failed$'\n' 
                #echo $(tput setaf 1)Failed: $(tput setaf 7)Lasssan...$'\n' 
                get_credentials;
        fi
}
get_credentials;
export_db(){
echo Exporting database...
wp db export --no-create-db=true $db.sql
}

export_db;

rsync_files(){
if [ -z "$path" ]
then
        echo $'\n'Transferring files...
        rsync -avuz --progress $webroot $user@$ip://home/master/applications/$db/public_html
else
        echo $'\n'Transferring files...
        rsync -avuz --progress $path $user@$ip://home/master/applications/$db/public_html
fi
}
rsync_files;

exit_confirmation(){
echo $(tput setaf 7)$'\n'Transer complete? "Enter (1,2 or 3):"
        select yn in "Yes" "Run rsync again" "Export database again"; do
        case $yn in
        Yes ) break;;
        "Run rsync again" ) rsync_files; exit_confirmation;;
        "Export database again" ) export_db; exit_confirmation;;
        esac
done
}
exit_confirmation;
rm ./$db.sql
rm ./prefix.txt
#rm ./source.sh
echo Exiting...
exit;
