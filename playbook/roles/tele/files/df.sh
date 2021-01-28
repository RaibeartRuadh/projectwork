#!/bin/bash

if [ "`df | grep "/dev/sda1" | awk '{print $5}' | sed 's/\%//'`" -ge 10 ]; 
 then echo "Disk usage exceeded 95%" | curl -s -X POST https://api.telegram.org/bot1493001337:AAEHNRl87mm47EfqY-d4b-_RWWcEvrZuANk/sendMessage -d chat_id=-469980725 -d text="Info - диск заполнен на 10%! - проверка";
fi

if [ "`df | grep "/dev/sda1" | awk '{print $5}' | sed 's/\%//'`" -ge 95 ]; 
 then echo "Disk usage exceeded 95%" | curl -s -X POST https://api.telegram.org/bot1493001337:AAEHNRl87mm47EfqY-d4b-_RWWcEvrZuANk/sendMessage -d chat_id=-469980725 -d text="Warning - диск заполнен на 95%!";
fi

if [ "`df | grep "/dev/sda1" | awk '{print $5}' | sed 's/\%//'`" -ge 99 ]; 

then echo "Disk usage exceeded 99%!" | curl -s -X POST https://api.telegram.org/bot1493001337:AAEHNRl87mm47EfqY-d4b-_RWWcEvrZuANk/sendMessage -d chat_id=-469980725 -d text="Critical - диск заполнен на 99%!";

fi

