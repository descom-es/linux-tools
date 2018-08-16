#!/usr/bin/env bash

APPPATH=`/usr/bin/dirname $0`
APPPATH="${APPPATH}/../"

PATH_VAR="${APPPATH}/var/"
PATH_LIB="${APPPATH}/lib/"

if [ -f "$APPPATH/etc/backup.cfg" ];then
    . "$APPPATH/etc/backup.cfg"
fi

if [ -f "${PATH_VAR}" ]; then
    echo "{\"message\": \"The directory backup is a file\"}"
    exit 1
fi

if [ ! -d "${PATH_VAR}" ]; then
    mkdir -p "${PATH_VAR}"
fi

. "${PATH_LIB}/detectauth.sh"

MYSQL="mysql ${MYSQL_AUTH} -BN"

STATUS_EXIT=0

OUT="[";

NUM_OK=0
NUM_ERROR=0
NUM_NOTE=0
NUM_WARNING=0
NUM_INFO=0
NUM_UNKNOWN=0

DATA=""

for TB in `$MYSQL -e "SELECT CONCAT(TABLE_SCHEMA, '.', TABLE_NAME) as name FROM information_schema.TABLES WHERE ENGINE IN ('InnoDB', 'MyISAM') AND TABLE_SCHEMA<>'information_schema'"`; do
	DB=`echo "$TB" | awk -F "." '{print $1}'`
	TB=`echo "$TB" | awk -F "." '{print $2}'`
	TB="\`${DB}\`.\`${TB}\`"
		
	RESULT=`$MYSQL -e "CHECK TABLE $TB" | awk '{ printf $1"|"$3"|"; for (i=4; i<NF; i++){ printf $i" ";};print $NF }'`
	MSG_TYPE=`echo $RESULT | awk -F "|" '{print $2}' | awk '{print tolower($0)}'`
	MSG=`echo "$RESULT" | awk -F "|" '{print $NF}'`

	case "$MSG_TYPE" in
		status)
			((NUM_OK++))
			;;
		info)
			((NUM_INFO++))
			;;
		note)
			((NUM_NOTE++))
			;;
		warning)
			((NUM_WARNING++))
			DATA=$DATA", {\"table\": \"$TB\", \"type\": \"$MSG_TYPE\", \"msg\": \"$MSG\"}"
			;;
		error)
			((NUM_ERROR++))
			DATA=$DATA", {\"table\": \"$TB\", \"type\": \"$MSG_TYPE\", \"msg\": \"$MSG\"}"
			;;
		*)
			((NUM_UNKNOWN++))
			DATA=$DATA", {\"table\": \"$TB\", \"type\": \"$MSG_TYPE\", \"msg\": \"$MSG\"}"
			;;
	esac
done


if [ $NUM_ERROR -gt 0 ]; then
	STATUS="error"
	STATUS_EXIT=2
elif [ $NUM_WARNING -gt 0 ]; then
	STATUS="warning"
	STATUS_EXIT=1
elif [ $NUM_UNKNOWN -gt 0 ]; then
        STATUS="unknown"
	STATUS_EXIT=3
else
	STATUS="ok"
	STATUS_EXIT=0
fi

echo "{\"status\": \"$STATUS\", \"statuses\": {\"ok\": $NUM_OK, \"error\": $NUM_ERROR, \"warning\": $NUM_WARNING, \"info\": $NUM_INFO, \"note\": $NUM_NOTE, \"unknown\": $NUM_UNKNOWN}, \"data\": [${DATA:1}]}" > "$PATH_VAR"/status_mysql_check.status

OUT="{\"status\": \"$STATUS\", \"statuses\": {\"ok\": $NUM_OK, \"error\": $NUM_ERROR, \"warning\": $NUM_WARNING, \"info\": $NUM_INFO, \"note\": $NUM_NOTE, \"unknown\": $NUM_UNKNOWN}}"
echo $OUT

exit 0
