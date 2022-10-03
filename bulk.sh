#!/bin/bash
#read -p "Enter primary email: " email
#read -p "Enter API key: " apikey

# FETCH AND STORE ACCESS TOKEN
get_accesstoken() {
access_token=$(curl -s -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data '{"email" : "'$email'", "api_key" : "'$apikey'"}'  'https://api.cloudways.com/api/v1/oauth/access_token'  | jq -r '.access_token');
}

# FETCH SERVER LIST
get_serverList() {
curl -s -X GET --header 'Accept: application/json' --header 'Authorization: Bearer '$access_token'' 'https://api.cloudways.com/api/v1/server' > /home/elisha/myscripts/test/server-list.txt;
}

# GET APP DB USERS/NAMES ON THE ACCOUNT
get_DBnames() {
curl -s -X GET --header 'Accept: application/json' --header 'Authorization: Bearer '$access_token'' 'https://api.cloudways.com/api/v1/server' | jq -r '.servers[] | select (.status == "running").apps[].mysql_user' > users.txt 
readarray -t  dbnames < <(cat /home/elisha/myscripts/test/users.txt);
}
# GET APP PASSWORDS ON THE ACCOUNT
get_DBpw() {
curl -s -X GET --header 'Accept: application/json' --header 'Authorization: Bearer '$access_token'' 'https://api.cloudways.com/api/v1/server' | jq -r '.servers[] | select (.status == "running").apps[].mysql_password' > dbpw.txt
readarray -t dbpw < <(cat /home/elisha/myscripts/test/dbpw.txt);
}

# GET MASTER USERNAMES ON THE ACCOUNT
get_SSHusers() {
jq -r '.servers[] | select (.status == "'running'").master_user' /home/elisha/myscripts/test/server-list.txt  > /home/elisha/myscripts/test/sshusers.txt
readarray -t sshuser < <(cat /home/elisha/myscripts/test/sshusers.txt);
}

# GET MASTER PASSWORD ON THE ACCOUNT
get_SSHpw() {
jq -r '.servers[] | select (.status == "'running'").master_user' /home/elisha/myscripts/test/server-list.txt  > /home/elisha/myscripts/test/sshpw.txt
readarray -t sshpw < <(cat /home/elisha/myscripts/test/sshpw.txt);
}

# GET IPs OF SERVER(S) ON THE ACCOUNT
get_srvIP() {
jq -r '.servers[] | select (.status == "'running'").public_ip' /home/elisha/myscripts/test/server-list.txt  > /home/elisha/myscripts/test/srvip.txt
readarray -t srvIP < <(cat /home/elisha/myscripts/test/srvip.txt);
}
get_accesstoken;
get_serverList;
get_SSHusers;
get_SSHpw;
get_srvIP;

# CONNECT TO EACH RUNNING SERVER AND PERFORM A TASK
do_task() {
for i in ${!sshuser[@]}; do
	#echo "Master user: ${sshuser[$i]}";
	#echo "Master PW: ${sshpw[$i]}";
	sshpass -p ${sshpw[$i]} ssh -t ${sshuser[$i]}@${srvIP[$i]} 1>/dev/null 2> /dev/null << "ENDSSH"
	for app in $(ls -l /home/master/applications/ | awk '/^d/ {print $NF}'); do
	cd /home/master/applications/$app/public_html/;
 	#wp plugin deactivate malcare-security;
	touch ping.txt
	cd /home/master/applications/;
	done;
ENDSSH
	echo $'\n'Exiting server ${srvIP[$i]};
done
}
do_task;
rm srvip.txt sshusers.txt  sshpw.txt; 
exit;
