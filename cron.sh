#!/bin/bash
echo Fetching running crons of all applications...;
cd /home/master/applications/
for A in $(ls | awk '{print $NF}'); do echo $'\n'$(tput setaf 4)$A $(tput setaf 7); cat $A/conf/server.nginx | awk '{print $NF}' | head -n1 && sudo apm -s $A cron; done
cd - && rm cron.sh
exit;
