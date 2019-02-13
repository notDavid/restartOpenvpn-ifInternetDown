#!/bin/bash

website=apple.com
UP="Internet connection succeeded :)"
DOWN="Internet connection FAILED :'("
STATUS="$DOWN"
SLEEP_DEFAULT=600
SLEEP=0
i=0
isleep=0
spin='-\|/'

echo "Checking if internet is up every $SLEEP_DEFAULT seconds..."
while :
do
  if [ "$isleep" -eq "$SLEEP" ]; then
    SLEEP=$SLEEP_DEFAULT
    isleep=0
    if netcat -zw1 $website 443 2>/dev/null && echo |openssl s_client -connect $website:443 2>&1 |awk '
    handshake && $1 == "Verification" { if ($2=="OK") exit; exit 1 }
    $1 $2 == "SSLhandshake" { handshake = 1 }' ; then
      if [ "$STATUS" == "$DOWN" ]; then
        echo "$(date +%d-%m-%Y_%H:%M:%S) $UP"
      fi
      STATUS=$UP
    else
      echo "$(date +%d-%m-%Y_%H:%M:%S) $DOWN"
      if [ "$STATUS" == "$DOWN" ]; then
        echo "$(date +%d-%m-%Y_%H:%M:%S) Restarting openvpn..."
        set -x
        #systemctl restart openvpn@yourclient.service
        systemctl restart openvpn.service
        set +x
        SLEEP=90
      else
        #first wait 30 seconds, test again, and if it fails again then restart openvpn
        STATUS=$DOWN
        SLEEP=30
      fi
    fi
  fi
  #spinning wheel
  i=$(( (i+1) %4 ))
  printf "\r${spin:$i:1}"
  #
  sleep 1
  isleep=$[$isleep +1]
done

