USERID="-469980725"
KEY="1493001337:AAEHNRl87mm47EfqY-d4b-_RWWcEvrZuANk"
TIMEOUT="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
DATE_EXEC="$(date "+%d %b %Y %H:%M")"
TMPFILE='/tmp/ipinfo-$DATE_EXEC.txt'
if [ -n "$SSH_CLIENT" ]; then
        IP=$(awk '{print $1}' <<< $SSH_CLIENT)
        PORT=$(awk '{print $3}' <<< $SSH_CLIENT)
        HOSTNAME=$(hostname -f)
        IPADDR=$(hostname -I | awk '{print $1}')
        curl http://ipinfo.io/$IP -s -o $TMPFILE
        CITY=$(jq -r '.city' < $TMPFILE)
        REGION=$(cat $TMPFILE | jq '.region' | sed 's/"//g')
        COUNTRY=$(cat $TMPFILE | jq '.country' | sed 's/"//g')
        ORG=$(cat $TMPFILE | jq '.org' | sed 's/"//g')
        TEXT="$DATE_EXEC: Вход пользователя ${USER} по ssh на $HOSTNAME
($IPADDR) из $IP - $ORG - $CITY, $REGION, $COUNTRY через порт $PORT"
        curl -s --max-time $TIMEOUT -d "chat_id=$USERID&disable_web_page_preview=1&text=$TEXT" $URL > /dev/null
        rm $TMPFILE
fi




