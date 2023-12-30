#!/bin/sh

SERVICE="/jffs/tg.sh"

mv /tmp/mnt/Transcend/Download2/Complete/* /tmp/mnt/Transcend/xStorage/xTorrents/

ps | grep -v grep | grep $SERVICE > /dev/null
result=$?
if [ "${result}" -eq "1" ] ; then
   bash $SERVICE &
fi

exit 0