#!/usr/bin/env bash

APPPATH=`/usr/bin/dirname $0`
APPPATH="${APPPATH}/../"

PATH_LIB="${APPPATH}/lib/"

if [ -f "$APPPATH/etc/backup.cfg" ];then
    . "$APPPATH/etc/backup.cfg"
fi

. "${PATH_LIB}/detectauth.sh"

MYSQL="mysql ${MYSQL_AUTH}"

$MYSQL -e 'select now()'

exit $?
