#!/usr/bin/env bash

APPPATH=`/usr/bin/dirname $0`
APPPATH="${APPPATH}/../"

DB_EXCLUDES=("information_schema" "performance_schema")
PATH_BACKUP="${APPPATH}/var/"
PATH_LIB="${APPPATH}/lib/"

if [ -f "$APPPATH/etc/backup.cfg" ];then
    . "$APPPATH/etc/backup.cfg"
fi

if [ -f "${PATH_BACKUP}" ]; then
    echo "{\"message\": \"The directory backup is a file\"}"
    exit 1
fi

if [ ! -d "${PATH_BACKUP}" ]; then
    mkdir -p "${PATH_BACKUP}"
fi

. "${PATH_LIB}/detectauth.sh"

dbs=$(mysql ${MYSQL_AUTH} -BN -e "show databases")

if [ $? != 0 ];then
    echo "{\"message\": \"Fail to get databases\"}"
    exit 2
fi

EXIT_CODE=0

JSON_DB_OK=""
JSON_DB_ERR=""

for db in $dbs;do
    IS_EXCLUDE=0

    for exclude in "${DB_EXCLUDES[@]}"; do
        if [ "$exclude" == "$db" ]; then
            IS_EXCLUDE=1
        fi
    done

    if [ $IS_EXCLUDE == 0 ]; then
        mysqldump --opt --routines=true ${MYSQL_AUTH} $db | gzip -c > "${PATH_BACKUP}/bck_$db.gz"
        if [ $? != 0 ];then
            JSON_DB_ERR="${JSON_DB_ERR}${db}; "
            EXIT_CODE=3
        else
            JSON_DB_OK="${JSON_DB_OK}${db}; "
        fi
    fi
done

if [ $EXIT_CODE -eq 0 ];then
    echo "{\"message\": \"Backup doing succefull\", \"ok\": \"${JSON_DB_OK}\"}"
else
    echo "{\"message\": \"Backup doing succefull\", \"ok\": \"${JSON_DB_OK}\", \"error\": \"${JSON_DB_ERR}\"}"
fi

exit $EXIT_CODE
