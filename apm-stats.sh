#!/bin/bash
# Purpose: Get server stats for a certain duration
# Author: Elisha | Cloudways
# Last Edited: 15/03/2022:17:29

set -e
cd /home/master/applications/
date_to_check=$1
time_in_UTC=$2
interval_in_mins=$3

# Adding option to select interval (days/hr/mins)
iv=$4

if [ -z $date_to_check ] && [ -z $time_in_UTC ] && [ -z $interval_in_mins ] && [ -z $iv ]; 
  then
    echo "Fetching logs for the last$(tput setaf 1) 24 hours$(tput setaf 7) ...";
    for A in $(ls | awk '{print $NF}'); do echo $'\n'$(tput setaf 4)$A $(tput setaf 7); cat $A/conf/server.nginx | awk '{print $NF}' | head -n1 && sudo apm traffic -s $A -l 1d; sudo apm mysql -s $A -l 1d; sudo apm php -s $A --slow_pages -l 1d; done;

elif [ -z $iv ] 
  then
    # Setting interval to mins if empty
    iv="min";
fi

dd=$(echo $date_to_check | cut -d '/' -f1);
mm=$(echo $date_to_check | cut -d '/' -f2);
yy=$(echo $date_to_check | cut -d '/' -f3);

# Convert input date to m/d/y format 
date_new="$mm/$dd/$yy"

from_param=$(date --date="$date_new $time_in_UTC UTC -$interval_in_mins $iv" -u +'%d/%m/%Y:%H:%M');

until_param=$(date --date="$date_new $time_in_UTC UTC +$interval_in_mins $iv" -u +'%d/%m/%Y:%H:%M');

echo Stats from $(tput setaf 3)$from_param $(tput setaf 7)to $(tput setaf 3)$until_param $(tput setaf 7)$'\n'
for A in $(ls | awk '{print $NF}'); do echo $'\n'$(tput setaf 4)$A $(tput setaf 7); cat $A/conf/server.nginx | awk '{print $NF}' | head -n1 && sudo apm -s $A traffic --from $from_param --until $until_param; sudo apm -s $A mysql --from $from_param --until $until_param; sudo apm -s $A php --slow_pages --from $from_param --until $until_param; done
cd - && rm apm-stats.sh;
exit;
