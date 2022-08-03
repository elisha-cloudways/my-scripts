#!/bin/bash
# Install PHPMyadmin v5.2.0

wget https://files.phpmyadmin.net/phpMyAdmin/5.2.0/phpMyAdmin-5.2.0-english.zip
unzip phpMyAdmin-5.2.0-english.zip
mv phpMyAdmin-5.2.0-english phpmyadmin
rm -rf phpMyAdmin-5.2.0-english.zip
