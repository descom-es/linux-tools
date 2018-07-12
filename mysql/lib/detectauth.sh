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
