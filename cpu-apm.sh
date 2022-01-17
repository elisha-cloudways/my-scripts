#!/bin/bash
cd /home/master/applications/
# for A in $(ls -l /home/master/applications/| grep "^d" | awk '{print $NF}'); do echo $A && awk '{print $1,$7}' /home/master/applications/$A/logs/apache_*.access.log | cut -d? -f1 | sort | uniq -c |sort -nr | head -n 5 | awk -F";" '{print $1}' ; done
for A in $(ls | awk '{print $NF}'); do echo $'\n'$(tput setaf 3)$A $(tput setaf 7); cat $A/conf/server.nginx | awk '{print $NF}' | head -n1 && sudo apm traffic -s $A -l 1d; sudo apm mysql -s $A -l 1d; sudo apm php -s $A --slow_pages -l 1d; done
cd - && rm cpu-apm.sh
exit;
