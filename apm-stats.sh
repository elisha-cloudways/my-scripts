#!/bin/bash
# Purpose: Get server stats for a certain duration
# Author: Elisha | Cloudways
# Last Edited: 18/03/2022:15:30
# Pushed from testing to main on 29/03/2022:16:30

set -e
cd /home/master/applications/
date_to_check=$1
time_in_UTC=$2
interval_in_mins=$3

# Adding option to select interval (days/hr/mins)
iv=$4

# Function to fetch stats for a particular time duration
get_stats(){
dd=$(echo $date_to_check | cut -d '/' -f1);
mm=$(echo $date_to_check | cut -d '/' -f2);
yy=$(echo $date_to_check | cut -d '/' -f3);

# Convert input date to m/d/y format 
date_new="$mm/$dd/$yy"

time_a="$date_to_check:$time_in_UTC"
time_b=$(date --date="$date_new $time_in_UTC UTC $interval_in_mins $iv" -u +'%d/%m/%Y:%H:%M');
time_op=$(echo $interval_in_mins |  cut -c1-1);

if [[ "$time_op" = "-" ]];
then
        from_param=$time_b;
        until_param=$time_a;
elif [[ "$time_op" = "+" ]];
then
        from_param=$time_a;
        until_param=$time_b;
fi

echo Stats from $(tput setaf 3)$from_param $(tput setaf 7)to $(tput setaf 3)$until_param $(tput setaf 7)$'\n'
for A in $(ls | awk '{print $NF}'); do echo $'\n'$(tput setaf 4)$A $(tput setaf 7); cat $A/conf/server.nginx | awk '{print $NF}' | head -n1 && sudo apm -s $A traffic --from $from_param --until $until_param; sudo apm -s $A mysql --from $from_param --until $until_param; sudo apm -s $A php --slow_pages --from $from_param --until $until_param; done
}

if [ -z $date_to_check ] && [ -z $time_in_UTC ] && [ -z $interval_in_mins ] && [ -z $iv ];
  then
    read -p 'Enter duration: ' dur
    echo "Fetching logs for the last$(tput setaf 1) $dur$(tput setaf 7) ...";
    for A in $(ls | awk '{print $NF}'); do echo $'\n'$(tput setaf 4)$A $(tput setaf 7); cat $A/conf/server.nginx | awk '{print $NF}' | head -n1 && sudo apm traffic -s $A -l $dur; sudo apm mysql -s $A -l $dur; sudo apm php -s $A --slow_pages -l $dur; done;

elif [ -z $iv ]
  then
    # Setting interval to mins if empty
    iv="min";
    get_stats;
  else
    get_stats;
fi;

# cd - && rm apm-stats.sh;
exit;
