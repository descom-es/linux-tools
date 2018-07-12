#!/usr/bin/env bash

APPPATH=`/usr/bin/dirname $0`
APPPATH="${APPPATH}/../"

PATH_INSTALL="/opt/descom/mysql_backup"

if [ ! -d "$PATH_INSTALL" ]; then
    mkdir -p "$PATH_INSTALL"
    chmod 750 "$PATH_INSTALL"
    cp -pr "${APPPATH}" "$PATH_INSTALL"
    chmod -R 750 "$PATH_INSTALL/bin/"

    if [ ! -f "/etc/cron.d/mysql_backup" ];then
        echo "30 1  * * *    root    ${PATH_INSTALL}/bin/backup.sh" > "/etc/cron.d/mysql_backup"
        service cron reload
    fi

    exit 0
else
    echo "${PATH_INSTALL} exists"
    MUST_UPGRADE="1"

    if [ -f "${PATH_INSTALL}/version" ]; then
        cur_version=`head -1 "${PATH_INSTALL}/version"`
        new_version=`head -1 "${APPPATH}/version"`

        if [ "$cur_version" == "$new_version" ]; then
            echo "Mysql Script was updated"
            MUST_UPGRADE="0"
        fi
    fi

    if [ "$MUST_UPGRADE" == "1" ]; then
        echo "upgrade ..."
        mv "${PATH_INSTALL}" /tmp/mysql_backup_cur

        mkdir -p "$PATH_INSTALL"
        chmod 750 "$PATH_INSTALL"
        cp -pr "${APPPATH}" "$PATH_INSTALL"
        chmod -R 750 "$PATH_INSTALL/bin/"

        mv /tmp/mysql_backup_cur/var "${PATH_INSTALL}"

        echo "upgrade ok"
    fi

    exit 0
fi
