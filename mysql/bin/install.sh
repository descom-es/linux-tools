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
        
        if [ -d /tmp/mysql_backup_cur ];then
            # REMOVE WHEN UPGRADE ALL, PATCH
            rm -rf /tmp/mysql_backup_cur
        fi
        
        if [ -d "${PATH_INSTALL}/../mysql_backup_var" ];then
            rm -rf "${PATH_INSTALL}/../mysql_backup_var"
        fi
 
        mv "${PATH_INSTALL}/var" "${PATH_INSTALL}/../mysql_backup_var"

        mkdir -p "$PATH_INSTALL"
        chmod 750 "$PATH_INSTALL"
        cp -pr "${APPPATH}" "$PATH_INSTALL"
        chmod -R 750 "$PATH_INSTALL/bin/"

        mv "${PATH_INSTALL}/../mysql_backup_var" "${PATH_INSTALL}"

        echo "upgrade ok"
    fi

    exit 0
fi
