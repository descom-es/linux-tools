#!/bin/bash

command -v apt-get > /dev/null

if [ $? == 0 ];then
    APP_UPGRADE="apt"
else
    command -v yum > /dev/null

    if  [ $? == 0 ];then
        APP_UPGRADE="yum"
    else
        echo "Error: Upgrade not supported"
        exit -1
    fi
fi

if [ $APP_UPGRADE == "apt" ]; then
    apt-get update > /dev/null
    if [ $? != 0 ]; then
        echo "Error: apt-get update failed"
        exit -1
    else
        NUM_UPDATES=$(/usr/bin/apt-get -s upgrade | grep "^Inst" | wc -l)
    fi
fi

if [ $APP_UPGRADE == "yum" ]; then
    NUM_UPDATES=$(/usr/bin/yum -q check-update 2>/dev/null | /bin/grep -v '^$' | wc -l)
fi

echo "${NUM_UPDATES} upgrades pending"
exit $NUM_UPDATES
