#!/bin/bash
# Purpose: Debug server load
# Author: Elisha | Cloudways
# Last Edited: 20/05/2022:04:45

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
mm=$(echo $date_to_check | cut -d '/' -f2);Stats from 
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
top_five=$(for i in $(ls -l | grep -v ^l | awk '{print $NF}' | awk 'FNR > 1'); do count=$(sudo apm -s $i traffic --statuses --from $from_param --until $until_param -j | grep -Po "\d..\",\d*" | cut -d ',' -f2 | head -n1); echo $i:$count ; done | sort -k2 -nr -t ":" | cut -d : -f 1 | head -n 5) ; done
for A in $top_five; do echo $'\n'$(tput setaf 4)$A $(tput setaf 7); cat $A/conf/server.nginx | awk '{print $NF}' | head -n1 && sudo apm -s $A traffic -n5 --from $from_param --until $until_param; sudo apm -s $A mysql -n5 --from $from_param --until $until_param; sudo apm -s $A php -n5 --slow_pages --from $from_param --until $until_param; done
}


if [ -z $date_to_check ] && [ -z $time_in_UTC ] && [ -z $interval_in_mins ] && [ -z $iv ];
  then
    read -p 'Enter duration: ' dur
    echo "Fetching logs for the last$(tput setaf 1) $dur$(tput setaf 7) ...";
    top_five=$(for i in $(ls -l | grep -v ^l | awk '{print $NF}' | awk 'FNR > 1'); do count=$(sudo apm -s $i traffic --statuses -l $dur -j | grep -Po "\d..\",\d*" | cut -d ',' -f2 | head -n1); echo $i:$count ; done | sort -k2 -nr -t ":" | cut -d : -f 1 | head -n 5) ; done
    for A in $top_five; do echo $'\n'$(tput setaf 4)$A $(tput setaf 7); cat $A/conf/server.nginx | awk '{print $NF}' | head -n1 && sudo apm traffic -s $A -l $dur -n5; sudo apm mysql -s $A -l $dur -n5; sudo apm php -s $A --slow_pages -l $dur -n5; done;

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

# USAGE-examples

# bash apm-stats.sh <date> <Time-in-UTC> <time-interval> min/hour/day

# bash apm-stats.sh 19/05/2022 15:00 -15 min (Stats from 19/05/2022:14:45 to 19/05/2022:15:00)
# bash apm-stats.sh 19/05/2022 15:00 +1 hour (Stats from 19/05/2022:15:00 to 19/05/2022:16:00)

# Example: Idle CPU 0% from 19/05/2022:15:00 to 19/05/2022:15:10
# bash apm-stats.sh 19/05/2022 15:00 +10 min
