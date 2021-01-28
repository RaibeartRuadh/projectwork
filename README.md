#Проектная работа (в процессе дополнения - описательная часть)

Цель: Создание рабочего проекта
веб проект с развертыванием нескольких виртуальных машин
должен отвечать следующим требованиям
- включен https
- основная инфраструктура в DMZ зоне
- файрвалл на входе
- сбор метрик и настроенный алертинг
- везде включен selinux
- организован централизованный сбор логов

#Реализация
## Цели проекта:
- Развернуть стенд, состоящий из нескольких виртуальных машин, который бы отвечал заданным требованиям. В качестве основного web-приложение будет использоваться WordPress — система управления содержимым сайта с открытым исходным кодом. Дополнительно была развернута система резервного копирования данных Borg, основным преимуществом которого является дедупликация и гибкая очистка от старых бэкапов.

Для автоматического развертывания стенда используется ПО Ansible 2.9, ПО для создания и конфигурирования виртуальной среды разработки - Vagrant 2.2.6 и ПО для эмуляции аппаратного обеспечения компьютера - VirtualBox 6.0

Запуск стенда:

		`$ vagrant up`

Развертывание стенда может занять продолжительное время (от 20 до 30 минут) Завершение работы сценария на иллюстрации ниже:
![Иллюстрация к проекту](screenshots/pic0.png)

## Основной адрес (wordpress)

		https://192.168.100.11/wp-login.php

Wordpress развернут на хосте 192.168.100.12 - на 192.168.100.11 он проксирован.

Стартовая странички для кастомизации настроек и управления Wordpress
![Иллюстрация к проекту](screenshots/pic1.png)
Страничка сайта по-умолчанию
![Иллюстрация к проекту](screenshots/pic2.png)

## Мониторинг и аллертинг
Для реализации задачи были написаны роли для Node Exporter, Grafana и Prometheus.
Адрес системы мониторинга (Grafana)

		https://192.168.100.13:3000/login

Стартовая странички авторизации в Grafana
![Иллюстрация к проекту](screenshots/pic3.png)

Для получения доступа к данным мониторинга, выполните:
- введите логин и пароль: admin admin. При входе Grafana предложит сменить стартовый пароль на новый.
- введите новый логин и пароль
- В боковом выберите Dashboards - manages и выберите подготовленный dashboard - `RaibeartRuadh Dashboards`
- Выбранная панель отображает собираемые Prometheus метрики по следующим категориям:

		`- Load Average`
		`- Memory`
		`- Disk size`
		`- Disk I/O`
		`- Network `

Графики на Dashboard
![Иллюстрация к проекту](screenshots/pic4.png)


Аллертинг: Используются две категории:
- Предупреждение в телеграм-канал о входе по ssh на любой из хостов
- Предупреждение в телеграмм-канал о достижении заданного значения заполнения основного диска /dev/sda1 на каждом из хостов (установлены значения 10% для демонстрации. 95% и 99%)

Для отслеживания состояния заполнения основного диска используется система юнит-сервисов - юнит-таймер и юнит-инициатор, вызывающий скрипт.
Для уведомления о входе по ssh используется скрипт /etc/profile.d, вызываемый при ssh авторизации.

		ssh-to-telegram.sh
		
		USERID="-435987725"
		KEY="1493023337:AAEHNRl874m46EfqY-d4b-_RWWcEvrZuANk"
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
Пример:

![Иллюстрация к проекту](screenshots/pic9.png)

При входе по SSH не в виртуальной сети должны выводиться данные (пример):

		28 Jan 2021 04:41: 
		Вход пользователя root по ssh 
		на new.site.com (192.168.15.32) из 22.215.110.218 - 
		AS31323 United Networks Ltd. - 
		Saint Petersburg, St.-Petersburg, RU
		через порт 22


## Центральное логирование

На каждом хосте устанавливается systemd-journal-gateway - http-демон, открывающий порт для просмотра (или скачивания) записей журнала 
На хосте journal установлен systemd-journal-remote - демон, скачивающий или принимающий записи журналов на центральном сервере

Проверка логирования:
- Подключиться к хосту journal

 		$ vagrant ssh journal

- Выполнить команду

		$ sudo journalctl -D /var/log/journal/remote --follow

Выполнить какие-либо операции на других хостах, к примеру, рестарт сервисовб авторизуйтесь или выйдите из сессии (также через каждые 5 минут отработывает сервис borg)

![Иллюстрация к проекту](screenshots/pic5.png)


## Резервное копирование

Для обеспечения сохранения данных используется пакет Borg, собирающий данные со всех хостов:
- Бэкапы сохраняются на хосте backup 192.168.100.15 в директории /var/backup
- Исполнение выполнено через юниты: юнит-таймер и юнит-инициатор, вызывающий скрипт.
- Расписание - каждые 5 минут (для демонстрации). Управление осуществляется службами 
- Скрипт на резервирование:

		#!/bin/bash
		# лок на случай повторного запуска
		LOCKFILE=/tmp/lockfile
		if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
		    echo "Service already working!"
		    exit
		fi
		trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
		echo $$ > ${LOCKFILE}
		export BORG_RSH="ssh -i /root/.ssh/id_rsa"
		export BORG_REPO=ssh://borguser@192.168.100.15/var/backup/{{ inventory_hostname }}
		export BORG_PASSPHRASE='password'
		LOG="/var/log/borg_backup.log"
		[ -f "$LOG" ] || touch "$LOG"
		exec &> >(tee -i "$LOG")
		exec 2>&1
		# создание резервных записей
		borg create \
		  --verbose --stats --progress \
		  ::{{ inventory_hostname }}-'{now:%Y-%m-%d_%H:%M:%S}' \
		  /var/backup /etc
		# Очистка от старых резервных записей
		borg prune \
		  -v --list \
		  --keep-within 1m \
		  --keep-monthly 3 
		# удаляем лок
		rm -f ${LOCKFILE}

![Иллюстрация к проекту](screenshots/pic.png)

## База данных (Резервирование)

Для работы Wordpress установлен MySQL. Для сохранения дампа базы используется расписание в cron (каждые 5 минут для теста). Дамп сораняется на хосте 192.168.100.13 в директори /var/backup

![Иллюстрация к проекту](screenshots/pic6.png)



## Ferewall



## Selinux




------------------------------------------------------------------
Хосты: 

`  fwd: ip: '192.168.100.10'   ` 
`  front: ip: '192.168.100.11'  ` 
`  web: ip: '192.168.100.12'  `
`  db: ip: '192.168.100.13'   `
`  journal: ip: '192.168.100.14'  `
`  backup:  ip: '192.168.100.15'  `



## web Wordpress


Для того, чтобы это работало под SeLinux были добавлены правила:
Разрешение для использование 443 порта `http_port_t`
Исправление контекста для сертификатов, чтобы https смог их считать:
`chcon unconfined_u:object_r:httpd_config_t:s0 /home/vagrant/<NAMEOFCERTFILE.EXT> `
Разрешения на использование подключения к сети, базе данных и работы с wordpress
`httpd_sys_content_t`
`httpd_sys_rw_content_t`
`httpd_log_t`
`httpd_can_network_connect`
`httpd_can_network_connect_db`

firewalld 
прописано разрешение на порт 443


## db

На хосте развернуты:
- MySQL DB для работы Wordpress
- Prometheus для сбора метрик - установка написана как роль
- Node exporter - для сбора данных о состоянии сервера с подключаемыми коллекторами метрик. Он позволяет измерять различные ресурсы машины, такие как использование памяти, диска и процессора. установка написана как роль
- Grafana - для вывода данных метрик и настройки алертинга (в последних версиях это уже есть). установка написана как роль

После установки MySQL фоздается учетная запись для работы Wordpress
Создается расписание для крона под сохранения дампа базы. Для теста - каждые 5 минут

`- name: Cron job for mysql dump `
`  cron: `
`    name: dumpsql `
`    minute: "*/5" `
`    hour: "*" `
`    day: "*" `
`    month: "*" `
`    weekday: "*" `
`    job: 'mysqldump wordpress > "/var/backup/database.sql" --set-gtid-purged=OFF' `
` /var/backup/database.sql - где будут храниться бэкапы`
` —set-gtid-purged=OFF — указывает то, что мы не используем репликацию на основе глобальных идентификаторов GTID. `






## Selinux
Включен на каждом хосте. Проверка:
Подключиться к хосту и выполнить команду

` $ sestatus -v `

![Иллюстрация к проекту](pic2.png)


## fwd

Используется для создания сетевой инфраструктуры

Зонирование:
    `firewall-cmd --zone=external --change-interface=eth0`  
    `firewall-cmd --zone=internal --change-interface=eth1`  
    `firewall-cmd --zone=dmz --change-interface=eth2`  

Вход по http и https

    `firewall-cmd --zone=external --add-service=http`  
	
Маскарадинг
    `firewall-cmd --zone=external --add-masquerade`  
	
## backup	






