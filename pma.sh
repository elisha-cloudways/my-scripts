#!/bin/bash
# Install PHPMyadmin v5.1.3

wget https://files.phpmyadmin.net/phpMyAdmin/5.1.3/phpMyAdmin-5.1.3-english.zip
unzip phpMyAdmin-5.1.3-english.zip
mv phpMyAdmin-5.1.3-english phpmyadmin
rm -rf phpMyAdmin-5.1.3-english.zip

db=$(pwd | cut -d "/" -f 5);
i=$(cat /home/master/applications/$db/conf/server.nginx  | head -n 1 | wc -w);
if [[ "$i" == "2" ]]
        then
                dom=$(cat /home/master/applications/$db/conf/server.nginx | head -n 1 | awk '{print $2}')
                echo $'\n'"$(tput setaf 3)PHPMyAdmin URL: $(tput setaf 7)https://$dom/phpmyadmin"
else
        dom=$(cat /home/master/applications/$db/conf/server.nginx | head -n 1 | awk '{print $3}')
        echo $'\n'"$(tput setaf 3)PHPMyAdmin URL: $(tput setaf 7)https://$dom/phpmyadmin"
fi
rm pma.sh
