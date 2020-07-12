#!/bin/bash

set -e

echo "set mysql server ..."

if grep -q 'bind-address = 0.0.0.0' /etc/mysql/mysql.conf.d/mysqld.cnf; then

  rm -rf $cache_root_dir/mysql-need-restart.ok

else

  sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

  touch $cache_root_dir/mysql-need-restart.ok

fi

echo "[/etc/mysql/mysql.conf.d/mysqld.cnf]"
echo "===================================="
cat /etc/mysql/mysql.conf.d/mysqld.cnf
