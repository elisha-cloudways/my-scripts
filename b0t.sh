#!/bin/bash
cd /home/master/applications/
for d in ./*
do
        echo $'\n'$d
        cat $d/logs/apache_*.access.log | awk -F\" '{print $6}' | sort | uniq -c | sort -nr | head -20 | grep bot
done
rm ./b0t.sh
exit;
