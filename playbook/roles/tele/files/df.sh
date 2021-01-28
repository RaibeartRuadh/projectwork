#!/bin/bash

if [ "`df | grep "/dev/sda1" | awk '{print $5}' | sed 's/\%//'`" -ge 10 ]; 
 then echo "Disk usage exceeded 95%" | curl -s -X POST https://api.telegram.org/bot14!!!!337:AA!!!!!!!7EfqY-d4b-_RWWcEvrZuANk/sendMessage -d chat_id=-4!!!!!!725 -d text="Info - Тестовое уведомление. Диск заполнен больше чем на 10%!";
fi

if [ "`df | grep "/dev/sda1" | awk '{print $5}' | sed 's/\%//'`" -ge 95 ]; 
 then echo "Disk usage exceeded 95%" | curl -s -X POST https://api.telegram.org/bo!!!!!!!!!!337:AA!!!!!!!!!qY-d4b-_RWWcE!!ANk/sendMessage -d chat_id=-4!!!!980725 -d text="Warning - диск заполнен на 95%!";
fi

if [ "`df | grep "/dev/sda1" | awk '{print $5}' | sed 's/\%//'`" -ge 99 ]; 

then echo "Disk usage exceeded 99%!" | curl -s -X POST https://api.telegram.org/b!!!!!!!!!337:AAE!!!!!!!!!!qY-d4b-_RWWc!!!!uANk/sendMessage -d chat_id=-4!!!!!!25 -d text="Critical - диск заполнен на 99%!";

fi

