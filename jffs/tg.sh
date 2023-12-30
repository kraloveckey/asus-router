#!/bin/bash

master_id=USER_ID
token='TOKEN_ID'
api_url='https://api.telegram.org'
tele_url="$api_url/bot$token"

last_id=0
updates=""
updates_count=""
message=""
chat_id=""
message_text=""
message_id=""
reply_id=""
from_id=""

check_update() {
        updates="$(curl -s "$tele_url/getUpdates" --data-urlencode "offset=$(($last_id + 1))" --data-urlencode "timeout=5")"
        updates_count=$(echo "$updates" | grep -o '"message_id":[0-9]\+' | sed 's/^[^:]*://' | tail -n 1)
        last_id=$(echo "$updates" | grep -o '"update_id":[0-9]\+' | sed 's/^[^:]*://' | tail -n 1)
}

parse_json() {
        message="$(echo "$updates" | grep '"message":{"message_id":'$updates_count'')"
        chat_id="$(echo $message | grep -o '"chat":{"id":[0-9]\+' | sed 's/^[^:]*://' | sed 's/^[^:]*://')"
        message_text="$(echo $message | grep -o '"text":"[^"]\+' | sed 's/^[^:]*"//' | sed 's/^[^:]*://' | sed 's/^[^:]*"//')"
        message_id="$(echo "$message" | grep -o '"message_id":[0-9]\+' | sed 's/^[^:]*://')"
        reply_id="$(echo "$message" | grep -o '"reply_to_message":{"message_id":[0-9]\+' | sed 's/^[^:]*://' | sed 's/^[^:]*://')"
        from_id="$(echo "$message" | grep -o '"from":{"id":[0-9]\+' | head -n 1 | sed 's/^[^:]*://' | sed 's/^[^:]*://')"
}

reply_to_message() {
        curl -s "$tele_url/sendMessage" --data-urlencode "chat_id=$1" --data-urlencode "reply_to_message_id=$2" --data-urlencode "text=$3"
}

bash_command() {
        response_text="$(bash -c "$message_text 2>&1")"
        reply_to_message "$chat_id" "$message_id" "$response_text"
}

curl -s -X POST $tele_url/sendMessage -d chat_id=$master_id -d parse_mode=HTML -d text="<b>Wake up, Neo...%0AThe Matrix has you...%0AFollow the white rabbit.%0AKnock, knock, Neo.</b>"

while true; do
        ping -c1 $(echo "$tele_url" | cut -d '/' -f 3) 2>&1 > /dev/null && {

        check_update
        parse_json

        i="$(echo $message_text | wc -c)"
        if [ $i -lt 2 ]; then
            continue
        fi

        case $message_text in
            'ping'*)
                reply_to_message "$chat_id" "$message_id" "pong"
            ;;
            'vpn'*)
                response_text=`cat /jffs/syslog.log | grep "$(date "+%b %_d")" |  grep -a "Learn:" | sort -u 2>&1`
                reply_to_message "$chat_id" "$message_id" "$response_text"
            ;;
            'reboot'*)
                response_text=`reboot`
                reply_to_message "$chat_id" "$message_id" "$response_text"
            ;;
            *)
                bash_command
            ;;
        esac
        }
done