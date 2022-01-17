#!/bin/bash
cd /home/master/applications/
for A in $(ls | awk '{print $NF}'); do echo $'\n'$(tput setaf 3)$A $(tput setaf 7) && cat $A/conf/server.nginx | awk '{print $NF}' | head -n1; done
cd - && rm dbdom.sh
exit;
