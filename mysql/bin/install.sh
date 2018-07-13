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
        
        # REMOVE WHEN UPGRADE ALL, PATCH
        if [ -d /tmp/mysql_backup_cur ];then
            if [ ! -d "${PATH_INSTALL}/var" ];then  
                if [ -d /tmp/mysql_backup_cur/mysql_backup/var ];then
                    mv /tmp/mysql_backup_cur/mysql_backup/var "${PATH_INSTALL}"
                fi
            fi
            rm -rf /tmp/mysql_backup_cur
        fi
        # END PATCH
        
        yes | cp -pr "${APPPATH}/*" "${PATH_INSTALL}/"
        chmod -R 750 "${PATH_INSTALL}/bin/"
        
        echo "upgrade ok v$(cat ${PATH_INSTALL}/version)"
    fi

    exit 0
fi
