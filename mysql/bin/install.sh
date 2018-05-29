#!/usr/bin/env bash

APPPATH=`/usr/bin/dirname $0`
APPPATH="${APPPATH}/../"

PATH_INSTALL="/opt/descom/mysql_backup"

if [ ! -d "$PATH_INSTALL" ]; then
    mkdir -p "$PATH_INSTALL"
    chmod 750 "$PATH_INSTALL"

    cp -pr "${APPPATH}" "$PATH_INSTALL"

    chmod -R 750 "$PATH_INSTALL/bin/"

    if [ ! -f "/etc/crond.d/mysql_backup" ];then
        echo "30 1  * * *    root    ${PATH_INSTALL}/bin/backup.sh" > "/etc/crond.d/mysql_backup"
        service cron reload
    fi

    exit 0
else
    echo "${PATH_INSTALL} exists"
    exit 1
fi
