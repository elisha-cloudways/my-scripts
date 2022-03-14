#!/bin/bash
# Purpose: Get server stats for a certain duration
# Author: Elisha | Cloudways
set -e
date_to_check=$1
time_in_UTC=$2
interval_in_mins=$3

dd=$(echo $date_to_check | cut -d '/' -f1);
mm=$(echo $date_to_check | cut -d '/' -f2);
yy=$(echo $date_to_check | cut -d '/' -f3);

# Convert format 
date_new="$mm/$dd/$yy"

from_param=$(date --date="$date_new $time_in_UTC UTC -$interval_in_mins min" -u +'%d/%m/%y:%H:%M');

until_param=$(date --date="$date_new $time_in_UTC UTC +$interval_in_mins min" -u +'%d/%m/%y:%H:%M');

cd /home/master/applications/
for A in $(ls | awk '{print $NF}'); do echo $'\n'$(tput setaf 4)$A $(tput setaf 7); cat $A/conf/server.nginx | awk '{print $NF}' | head -n1 && sudo apm -s $A traffic --from $from_param --until $until_param; sudo apm -s $A mysql --from $from_param --until $until_param; sudo apm -s $A php --slow_pages --from $from_param --until $until_param; sudo apm -s $A cron --from $from_param --until $until_param; done
cd - && rm apm-stats.sh;
#exit;

