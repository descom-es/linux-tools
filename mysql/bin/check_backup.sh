#!/usr/bin/env bash

APPPATH=`/usr/bin/dirname $0`
APPPATH="${APPPATH}/../"

DB_EXCLUDES=("information_schema" "performance_schema")
PATH_BACKUP="${APPPATH}/var/"

if [ -f "$APPPATH/etc/backup.cfg" ];then
    . "$APPPATH/etc/backup.cfg"
fi

if [ -f "${PATH_BACKUP}" ]; then
    echo "{\"message\": \"The directory backup is a file\"}"
    exit 1
fi

#if [ ! -d "${PATH_BACKUP}" ]; then
#    mkdir -p "${PATH_BACKUP}"
#fi

if [ -z ${MYSQL_AUTH} ]; then
    if [ -f "/etc/psa/.psa.shadow" ];then
        MYSQL_PASS=`cat /etc/psa/.psa.shadow`
        MYSQL_AUTH=" -uadmin -p${MYSQL_PASS} "
    elif [ -f "/etc/mysql/debian.cnf" ];then
        U=$(cat /etc/mysql/debian.cnf | grep ^user | awk '{print $3}' | head -1)
        P=$(cat /etc/mysql/debian.cnf | grep ^password | awk '{print $3}' | head -1)
        MYSQL_AUTH=" -u${U} -p${P} "
    fi
fi

dbs=$(mysql ${MYSQL_AUTH} -BN -e "show databases")

if [ $? != 0 ];then
    echo "{\"message\": \"Fail to get databases\"}"
    exit 2
fi

EXIT_CODE=0

JSON_DB_OK=""
JSON_DB_ERR=""
PATH_BCK="/opt/descom/mysql_backup/var/"
for db in $dbs;do
    IS_EXCLUDE=0

    for exclude in "${DB_EXCLUDES[@]}"; do
        if [ "$exclude" == "$db" ]; then
            IS_EXCLUDE=1
        fi
    done
	
    if [ $IS_EXCLUDE == 0 ]; then
		finded= find ${PATH_BCK}bck_$db.gz -ctime -1 | wc -l > /dev/null
        if [ $? != 0 ];then
            JSON_DB_ERR="${JSON_DB_ERR}${db}; "
            EXIT_CODE=3
        else
			if [ finded = 1 ];then
				JSON_DB_OK="${JSON_DB_OK}${db}; "
			else
				JSON_DB_ERR="${JSON_DB_ERR}${db}; "
			fi
		fi
    fi
done

echo "{\"check_ok\": \"${JSON_DB_OK}\", \"check_error\": \"${JSON_DB_ERR}\"}"
exit $EXIT_CODE
