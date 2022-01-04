#!/bin/bash

echo -e "\nDisk usage:"; df -h /dev/vda1; echo $'\n'; du -shc /*  2>/dev/null |sort -rh | head -n 6
cd /home/master/applications/
for d in ./*/
do
        echo $'\n'$d
        sudo apm -s $d -d
        echo App folder taking most space: $'\n'
        du -h -d2 $d* 2>/dev/null | sort -hr | head -n 4
done
cd
rm ./chkdu.sh
exit;
