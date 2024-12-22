#!/bin/sh

SERVICE="/jffs/tg.sh"
SERVICE1="/jffs/smb.sh"
IPTABLES_PATH=$(iptables -L -n -v | grep 14887 | wc -l)
SMB_PATH=$(cat /etc/smb.conf | grep WHITE_IP | wc -l)

if [ "${IPTABLES_PATH}" -eq "0" ] ; then
   bash ${SERVICE1}
fi

if [ "${SMB_PATH}" -eq "0" ] ; then
   bash ${SERVICE1}
fi

ps | grep -v grep | grep ${SERVICE} > /dev/null
RESULT=$?
if [ "${RESULT}" -eq "1" ] ; then
   bash ${SERVICE} &
fi

mv /tmp/mnt/Transcend/Download2/Complete/* /tmp/mnt/Transcend/xStorage/xTorrents/

exit 0