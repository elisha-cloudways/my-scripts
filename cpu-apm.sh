#!/bin/bash
cd /home/master/applications/
for A in $(ls -l /home/master/applications/| grep "^d" | awk '{print $NF}'); do echo $A && awk '{print $1,$7}' /home/master/applications/$A/logs/apache_*.access.log | cut -d? -f1 | sort | uniq -c |sort -nr | head -n 5 | awk -F";" '{print $1}' ; done

for A in $(ls | awk '{print $NF}'); do echo $A && sudo apm traffic -s $A -l 1d; done
for A in $(ls | awk '{print $NF}'); do echo $A && sudo apm mysql -s $A -l 1d; done
for A in $(ls | awk '{print $NF}'); do echo $A && sudo apm php -s $A -l 1d; done

rm /cpu-apm.sh
