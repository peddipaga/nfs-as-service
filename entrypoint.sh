#!/bin/sh
set -e

count=0
HOSTNAME=$(hostname)
POD_ID=${HOSTNAME##*-}
NFS_COUNT=$(wc -l < /tmp/nfs.txt)

# echo $POD_ID $count

while read name
do
    # echo $name $count
    if [ $POD_ID -eq $count ]
    then
        echo "    server nfs${count} ${name} check" >> /usr/local/etc/haproxy/haproxy.cfg
    else
        echo "    server nfs${count} ${name} check backup" >> /usr/local/etc/haproxy/haproxy.cfg
    fi
    count=$(( count + 1 ))
done < /tmp/nfs.txt

cat /usr/local/etc/haproxy/haproxy.cfg
haproxy -f /usr/local/etc/haproxy/haproxy.cfg