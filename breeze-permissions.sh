#!/bin/bash
cd /home/master/applications/
for i in $(ls -l | grep '^d' | awk '{print $NF}'); do
cd $i/public_html/;
wp plugin is-active breeze --allow-root 2>/dev/null;
if [[ "$?" = "0" ]];
then
        touch wp-content/advance-cache.php;
        # echo "Breeze is installed";
        if [ ! -d wp-content/breeze-config ];
        then
                mkdir wp-content/breeze-config;
                touch wp-content/breeze-config/breeze-config.php;
        fi
        chown -R $i:www-data /home/master/applications/$i/public_html
        find -type d -exec chmod 775 {} ';'
        find -type f -exec chmod 664 {} ';'
fi
cd -
done
exit
