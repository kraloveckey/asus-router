#!/bin/sh

SERVICE="/jffs/tg.sh"
SERVICE1="/jffs/smb.sh"
CRON_PATH=$(cat /var/spool/cron/crontabs/parrot | wc -l)

mv /tmp/mnt/Transcend/Download2/Complete/* /tmp/mnt/Transcend/xStorage/xTorrents/

if [ "${CRON_PATH}" -eq "1" ] ; then
   bash $SERVICE1
fi

ps | grep -v grep | grep $SERVICE > /dev/null
result=$?
if [ "${result}" -eq "1" ] ; then
   bash $SERVICE &
fi

exit 0