#!/bin/sh
DIR=.us-west-2-compute.internal
SQL_HOST=localhost
SQL_USUARIO=root
SQL_PASSWORD=1234567
# Instalar las actualizaciones del sistema
yum -y update
#Instalar paquetes wget,ntp,nscd
yum -y install wget ntp nscd
#Habilita, inicia y verifica el estado de los paquetes instalados
systemctl enable ntpd nscd
systemctl start ntpd nscd
systemctl status ntpd nscd

sleep 4

#Configura demonios para iniciar con el SO 
chkconfig ntpd on
chkconfig nscd on
#Configura swap en 1
echo "vm.swappiness = 1" >> /etc/sysctl.conf
#Inhabilita transparent_hugepage
echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
echo 'echo "never" > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.local
echo 'echo "never" > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.local
#Modificar valor de Selinux
sed 's/SELINUX=enforcing/SELINUX=disabled/g' -i /etc/selinux/config
cat /etc/selinux/config
#Configuracion de hosts
echo "Defina las direcciones ip  privadas de los nodos del cluster"
sleep 4

echo "Ip-1"

read IP1

echo "Ip-2"

read IP2

echo "Ip-3"

read IP3

echo "Ip-4"

read IP4

echo "Ip-5"

read IP5

arrIN1=(${IP1//./ })
arrIN2=(${IP2//./ })
arrIN3=(${IP3//./ })
arrIN4=(${IP4//./ })
arrIN5=(${IP5//./ })

echo "$IP1 			ip-${arrIN1[0]}-${arrIN1[1]}-${arrIN1[2]}-${arrIN1[3]}$DIR" >> /etc/hosts
echo "$IP2 			ip-${arrIN2[0]}-${arrIN2[1]}-${arrIN2[2]}-${arrIN2[3]}$DIR" >> /etc/hosts
echo "$IP3 			ip-${arrIN3[0]}-${arrIN3[1]}-${arrIN3[2]}-${arrIN3[3]}$DIR" >> /etc/hosts
echo "$IP4 			ip-${arrIN4[0]}-${arrIN4[1]}-${arrIN4[2]}-${arrIN4[3]}$DIR" >> /etc/hosts
echo "$IP5 			ip-${arrIN5[0]}-${arrIN5[1]}-${arrIN5[2]}-${arrIN5[3]}$DIR" >> /etc/hosts

cat /etc/hosts
#Instalacion de repo MariaDB 10.0
> /etc/yum.repos.d/MariaDB.repo

echo "
# MariaDB 10.0 CentOS repository list - created 2017-08-04 03:32 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
" >> /etc/yum.repos.d/MariaDB.repo

cat /etc/yum.repos.d/MariaDB.repo
#Instalacion de MariaDB-server y MariaDB-client
sleep 4

yum -y update

sleep 4

yum -y install MariaDB-server MariaDB-client

systemctl enable mysql
systemctl start mysql
systemctl status mysql

#mysql_secure_installation configuración
mysql --user=root <<_EOF
UPDATE mysql.user SET Password=PASSWORD("$SQL_PASSWORD") WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF

sleep 4

SQL_ARGS="-h $SQL_HOST -u $SQL_USUARIO -p$SQL_PASSWORD -s -e"

mysql $SQL_ARGS 'create database scm DEFAULT CHARACTER SET utf8;'
mysql $SQL_ARGS 'create user `scm`@`localhost` IDENTIFIED BY `scm`;'
mysql $SQL_ARGS 'grant all on scm.* TO `scm`@`%` IDENTIFIED BY `scm`;'

mysql $SQL_ARGS 'create database amon DEFAULT CHARACTER SET utf8;'
mysql $SQL_ARGS 'create user `amon`@`localhost` IDENTIFIED BY `amon`;'
mysql $SQL_ARGS 'grant all on amon.* TO `amon`@`%` IDENTIFIED BY `amon`;'

mysql $SQL_ARGS 'create database rman DEFAULT CHARACTER SET utf8;'
mysql $SQL_ARGS 'create user `rman`@`localhost` IDENTIFIED BY `rman`;'
mysql $SQL_ARGS 'grant all on rman.* TO `rman`@`%` IDENTIFIED BY `rman`;'

mysql $SQL_ARGS 'create database metastore DEFAULT CHARACTER SET utf8;'
mysql $SQL_ARGS 'create user `metastore`@`localhost` IDENTIFIED BY `metastore`;'
mysql $SQL_ARGS 'grant all on metastore.* TO `metastore`@`%` IDENTIFIED BY `metastore`;'

mysql $SQL_ARGS 'create database sentry DEFAULT CHARACTER SET utf8;'
mysql $SQL_ARGS 'create user `sentry`@`localhost` IDENTIFIED BY `sentry`;'
mysql $SQL_ARGS 'grant all on sentry.* TO `sentry`@`%` IDENTIFIED BY `sentry`;'

mysql $SQL_ARGS 'create database nav DEFAULT CHARACTER SET utf8;'
mysql $SQL_ARGS 'create user `nav`@`localhost` IDENTIFIED BY `nav`;'
mysql $SQL_ARGS 'grant all on nav.* TO `nav`@`%` IDENTIFIED BY `nav`;'

mysql $SQL_ARGS 'create database navms DEFAULT CHARACTER SET utf8;'
mysql $SQL_ARGS 'create user `navms`@`localhost` IDENTIFIED BY `navms`;'
mysql $SQL_ARGS 'grant all on navms.* TO `navms`@`%` IDENTIFIED BY `navms`;'

mysql $SQL_ARGS 'create database hue DEFAULT CHARACTER SET utf8;'
mysql $SQL_ARGS 'create user `hue`@`localhost` IDENTIFIED BY `hue`;'
mysql $SQL_ARGS 'grant all on hue.* to `hue`@`localhost` identified by `hue`;'

mysql $SQL_ARGS 'create database oozie;'
mysql $SQL_ARGS 'create user `oozie`@`localhost` IDENTIFIED BY `oozie`;'
mysql $SQL_ARGS 'grant all privileges on oozie.* to `oozie`@`localhost` identified by `oozie`;'
mysql $SQL_ARGS 'grant all privileges on oozie.* to `oozie`@`%` identified by `oozie`;'

mysql $SQL_ARGS 'create database sqoop;'
mysql $SQL_ARGS 'create user `sqoop`@`localhost` IDENTIFIED BY `sqoop`;'
mysql $SQL_ARGS 'grant all privileges on sqoop.* to `sqoop`@`localhost` identified by `sqoop`;'
mysql $SQL_ARGS 'grant all privileges on sqoop.* to `sqoop`@`%` identified by `sqoop`;'
 
sleep 4




