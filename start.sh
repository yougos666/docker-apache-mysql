#!/bin/bash

if [ -e /root/database_dump.lock ]
then
    echo  "Les dumps ont déjà été importés"
    /usr/bin/supervisord -n

else
    touch /root/database_dump.lock
fi


PATH_DIR_DUMP=/root/database_dump/
if [ -d $PATH_DIR_DUMP ]; then
    DUMP_LIST=$(ls -A ${PATH_DIR_DUMP})      
    for DUMP_FILE in $DUMP_LIST
    do
        /usr/sbin/mysqld &
        sleep 5
        echo "Creating database ${DUMP_FILE%%.*}"
        echo "Create DATABASE ${DUMP_FILE%%.*}" | mysql --default-character-set=utf8
        sleep 5
        curl file:${PATH_DIR_DUMP}/${DUMP_FILE} | mysql -u root ${DUMP_FILE%%.*} --default-character-set=utf8
        mysqladmin shutdown
        echo "finished"
    done
else
    rm /root/database_dump.lock;
fi


# Now the provided user credentials are added
/usr/sbin/mysqld &
sleep 5
echo "Creating user"
echo "CREATE USER '$user' IDENTIFIED BY '$password'" | mysql --default-character-set=utf8
echo "REVOKE ALL PRIVILEGES ON *.* FROM '$user'@'%'; FLUSH PRIVILEGES" | mysql --default-character-set=utf8
echo "GRANT SELECT ON *.* TO '$user'@'%'; FLUSH PRIVILEGES" | mysql --default-character-set=utf8
echo "finished"

if [ "$right" = "WRITE" ]; then
  echo "adding write access"
  echo "GRANT ALL PRIVILEGES ON *.* TO '$user'@'%' identified by '$password' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql --default-character-set=utf8
fi

# And we restart the server to go operational
mysqladmin shutdown
#echo "Starting MySQL Server"
#/usr/sbin/mysqld

/usr/bin/supervisord -n
