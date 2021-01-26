#Проектная работа

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

Что реализовано частично:
- включен https - графана идет по http, wordpress по https
В целом есть методика работы Grafana по https (будет описана ниже)
Есть еще множество досадных косяков в схеме работы

Что не реализовано:
- алертинг (не успел)

Запуск стенда:

`$ vagrant up`

Основной сайт Wordpress доступен по адресу https://192.168.100.12
Графана доступна по адресу http://192.168.100.13

------------------------------------------------------------------
Хосты: 

`  fwd: ip: '192.168.100.10'   `
`  front: ip: '192.168.100.11'  `
`  web: ip: '192.168.100.12'  `
`  db: ip: '192.168.100.13'   `
`  journal: ip: '192.168.100.14'  `
`  backup:  ip: '192.168.100.15'  `


##Центральное логирование

На каждом хосте устанавливается systemd-journal-gateway - http-демон, открывающий порт для просмотра (или скачивания) записей журнала 
На хосте journal установлен systemd-journal-remote - демон, скачивающий или принимающий записи журналов на центральном сервере

Проверка логирования:
Подключиться к хосту journal
$ vagrant ssh journal

Выполнить команду

$ sudo journalctl -D /var/log/journal/remote --follow

Выполнить какие-либо операции на других хостах, к примеру, рестарт сервисов (также через каждые 5 минут отработывает сервис по резервированию)

![Иллюстрация к проекту](pic1.png)



## web Wordpress

https://192.168.100.12

В качестве web-сервера используется Httpd (apache2)

Конфигурация сайта
Используются самоподписанные сертфикаты

<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName 192.168.100.12
    ServerAlias project.local
    SSLEngine on
    SSLCertificateFile /home/vagrant/mysite.localhost.crt
    SSLCertificateKeyFile /home/vagrant/device.key

    DocumentRoot /var/www/html/project.local/wordpress
    ErrorLog /var/www/html/project.local/log/error.log
    CustomLog /var/www/html/project.local/log/requests.log combined
</VirtualHost>
</IfModule>

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


### Вход в Grafana
Перейдите по 
http://192.168.100.13

При первом входе введите в качестве логина и пароля: admin/admin
Графана предложит сменить пароль - выполните это
Выберите Dashboards - manage в меню и выберите подготовленный dashboard - `RaibeartRuadh Dashboards`
Выбранная панель отображает метрики по следующим категориям:

		`- Load Average`
		`- Memory`
		`- Disk size`
		`- Disk I/O`

![Иллюстрация к проекту](pic3.png)

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

Прикрутил бэкапирование хостов
используя borg
Расписание - каждые 5 минут. Управление осуществляется службами 
backup-borg.timer
backup-borg.service (oneshot)
Скрипт на резервирование:

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

Бэкапы доступны в директории: /var/backup

![Иллюстрация к проекту](pic4.png)

