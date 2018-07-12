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

. "${PATH_LIB}/detectauth.sh"

dbs=$(mysql ${MYSQL_AUTH} -BN -e "show databases")

if [ $? != 0 ];then
    echo "{\"message\": \"Fail to get databases\"}"
    exit 2
fi

EXIT_CODE=0

STATUS=1
NUM_OK=0
NUM_KO=0
JSON_OK=""
JSON_KO=""

if [ -f ${PATH_BACKUP}error_last_backup ];
then
	STATUS=0
else
	for db in $dbs;do
		IS_EXCLUDE=0

		for exclude in "${DB_EXCLUDES[@]}"; do
			if [ "$exclude" == "$db" ]; then
				IS_EXCLUDE=1
			fi
		done
		
		if [ $IS_EXCLUDE == 0 ]; then
			finded=$(find ${PATH_BACKUP}bck_$db.gz -ctime -1 | wc -l)
			if [ $? != 0 ];then
				STATUS=0
				EXIT_CODE=3
			else
				if [ "$finded" = 1 ];then
					((NUM_OK++))
					JSON_OK="${JSON_OK}${db}; "
				else
					STATUS=0
					((NUM_KO++))
					JSON_KO="${JSON_KO}${db}; "
				fi
			fi
		fi
	done
fi

echo "{\"status\": \"${STATUS}\", \"statuses\": {\"ok\": \"${NUM_OK}\", \"error\": \"${NUM_KO}\"}, \"data\": {\"ok\": \"${JSON_OK}\", \"error\": \"${JSON_KO}\"}}" > "$PATH_BACKUP"/status_mysql_backup.status
echo "{\"status\": \"${STATUS}\", \"statuses\": {\"ok\": \"${NUM_OK}\", \"error\": \"${NUM_KO}\"}}"

exit $EXIT_CODE
