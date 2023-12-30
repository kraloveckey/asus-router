#!/bin/sh
touch /tmp/000init-start

sleep 2m

# Wait for all services to load
i=0
while [ $i -le 20 ]; do
   success_start_service=`nvram get success_start_service`
   if [ "$success_start_service" == "1" ]; then
       break
   fi
   i=$(($i+1))
   echo "autorun APP: wait $i seconds...";
   sleep 1
done

sleep 10s

# Kill Samba service, replace conf file with custom, and restart
for pid in `ps -w | grep smbd | grep -v grep | awk '{print $1}'`
do
   echo "killing $pid"
   kill $pid
done

cp /jffs/smb.conf /etc/
chmod 444 /etc/smb.conf
mkdir -p /var/run/samba/
/usr/sbin/smbd -D -s /etc/smb.conf

sleep 10s

iptables -I INPUT -p tcp --destination-port 14887 -j ACCEPT
iptables -I INPUT -p tcp --destination-port 8081 -j DROP

cp /jffs/username_crontab /var/spool/cron/crontabs/

bash /jffs/tg.sh &