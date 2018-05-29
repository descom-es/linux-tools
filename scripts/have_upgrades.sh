#!/bin/bash

command -v apt-get > /dev/null

if [ $? == 0 ];then
    APP_UPGRADE="apt"
else
    command -v yum > /dev/null

    if  [ $? == 0 ];then
        APP_UPGRADE="yum"
    else
        echo "{\"status\": false, \"message\": \"SO not is compatible\"}"
        exit -1
    fi
fi

if [ $APP_UPGRADE == "apt" ]; then
    apt-get update > /dev/null
    if [ $? != 0 ]; then
        echo "{\"status\": false, \"message\": \"apt-get update failed\"}"
        exit -1
    else
        PACKAGES=$(/usr/bin/apt-get -s upgrade | grep "^Inst" | awk '{print $2}')
        if [ $? != 0 ]; then
            echo "{\"status\": false, \"message\": \"apt-get upgrade failed\"}"
            exit -1
        fi
    fi
fi

if [ $APP_UPGRADE == "yum" ]; then
    PACKAGES=$(/usr/bin/yum -q check-update 2>/dev/null | /bin/grep -v '^$' | awk '{print $1}')
    if [ $? != 0 ]; then
        echo "{\"status\": false, \"message\": \"yum check-update failed\"}"
        exit -1
    fi
fi

UPDATES=$(echo "$PACKAGES" | /bin/grep -v '^$' | awk 'BEGIN {print "["} {printf "%s{\"name\": \"%s\"}",separator , $1; separator=", "} END {print "]"}')
NUM_UPDATES=$(echo "$PACKAGES" | /bin/grep -v '^$' | wc -l)

echo "{\"status\": true, \"count\": ${NUM_UPDATES}, \"packages\": ${UPDATES}}"
exit 0
