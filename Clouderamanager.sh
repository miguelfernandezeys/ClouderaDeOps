#!/bin/sh
# redirect stdout/stderr to a file
exec &> logfile.log

#variables
SQL_HOST=localhost
SQL_USUARIO=root
SQL_PASSWORD=1234567
FILEHOST=/etc/hosts
FILESYS=/etc/sysctl.conf
FILESELI=/etc/selinux/config
FILERC=/etc/rc.local
FILECLO=/etc/yum.repos.d/cloudera-manager.repo
FILEJAVA=/root/mysql-connector-java-5.1.42/mysql-connector-java-5.1.42-bin.jar /usr/share/java/mysql-connector-java.jar
# Instalar las actualizaciones del sistema
yum -y update
#Instalar paquetes wget,ntp,nscd
yum -y install wget ntp nscd
#Habilita, inicia y verifica el estado de los paquetes instalados
systemctl enable ntpd nscd
systemctl start ntpd nscd
systemctl status ntpd nscd

sleep 4

# Descarga de JDBC de MySQL

wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.42.tar.gz

tar zxvf mysql-connector-java-5.1.42.tar.gz

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

sleep 4

#Instalación de cloudera-manager repo

> /etc/yum.repos.d/cloudera-manager.repo

echo "
[cloudera-manager]
# Packages for Cloudera Manager, Version 5, on RedHat or CentOS 7 x86_64
name=Cloudera Manager
baseurl=https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/5.11.1/
gpgkey =https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/RPM-GPG-KEY-cloudera
gpgcheck = 1
" >> /etc/yum.repos.d/cloudera-manager.repo

cat /etc/yum.repos.d/cloudera-manager.repo

sleep 4

#Configuracion de hosts

chmod 600 ~/Glpi.pem

file "./nodos.properties"

if [ -f "$file" ];

then 
    echo "$file found"
. $file
else 
    echo "$file not found"
fi
k=0
for i in "${hosts[@]}";
do 
    echo ${hosts[k]}  ${dns[k]} >> /etc/hosts
   
k=$k+1

done

k=1

for i in "${hosts[@]}";
do 
scp -i "Glpi.pem" "$FILEHOST" ec2-user@${hosts[k]}:/home/ec2-user

scp -i "Glpi.pem" "$FILESYS" ec2-user@${hosts[k]}:/home/ec2-user

scp -i "Glpi.pem" "$FILESELI" ec2-user@${hosts[k]}:/home/ec2-user

scp -i "Glpi.pem" "$FILERC" ec2-user@${hosts[k]}:/home/ec2-user

scp -i "Glpi.pem" "$FILECLO" ec2-user@${hosts[k]}:/home/ec2-user

scp -i "Glpi.pem" "$FILEJAVA" ec2-user@${hosts[k]}:/home/ec2-user

ssh -i "Glpi.pem"  ec2-user@${hosts[k]}"sudo echo "never" > /sys/kernel/mm/transparent_hugepage/defrag | sudo echo "never" > /sys/kernel/mm/transparent_hugepage/enabled"

ssh -i "Glpi.pem"  ec2-user@${hosts[k]}"sudo cp /home/ec2-user/hosts /etc | sudo cp /home/ec2-user/sysctl.conf /etc | sudo cp /home/ec2-user/config /etc/selinux | sudo cp /home/ec2-user/rc.local /etc | sudo cp /home/ec2-user/cloudera-manager.repo /etc/yum.repos.d "

ssh -i "Glpi.pem"  ec2-user@${hosts[k]} "sudo yum -y update | sudo yum -y install ntp nscd wget | sudo systemctl enable ntpd nscd | sudo systemctl start ntpd nscd "

ssh -i "Glpi.pem"  ec2-user@${hosts[k]} "sudo mkdir /user/share/java | sudo cp /home/ec2-user/mysql-connector-java-5.1.42/mysql-connector-java-5.1.42-bin.jar /usr/share/java/mysql-connector-java.jar"

ssh -i "Glpi.pem"  ec2-user@${hosts[k]} "sudo yum -y install  cloudera-manager-daemons cloudera-manager-agent |sudo service cloudera-scm-agent enable | sudo service cloudera-scm-agent start "


k=$k+1

done

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
create database scm DEFAULT CHARACTER SET utf8;
create user 'scm'@'localhost' IDENTIFIED BY 'scm';
grant all on scm.* TO 'scm'@'%' IDENTIFIED BY 'scm';

create database amon DEFAULT CHARACTER SET utf8;
create user 'amon'@'localhost' IDENTIFIED BY 'amon';
grant all on amon.* TO 'amon'@'%' IDENTIFIED BY 'amon';

create database rman DEFAULT CHARACTER SET utf8;
create user 'rman'@'localhost' IDENTIFIED BY 'rman';
grant all on rman.* TO 'rman'@'%' IDENTIFIED BY 'rman';

create database metastore DEFAULT CHARACTER SET utf8;
create user 'metastore'@'localhost' IDENTIFIED BY 'metastore';
grant all on metastore.* TO 'metastore'@'%' IDENTIFIED BY 'metastore';

create database sentry DEFAULT CHARACTER SET utf8;
create user 'sentry'@'localhost' IDENTIFIED BY 'sentry';
grant all on sentry.* TO 'sentry'@'%' IDENTIFIED BY 'sentry';

create database nav DEFAULT CHARACTER SET utf8;
create user 'nav'@'localhost' IDENTIFIED BY 'nav';
grant all on nav.* TO 'nav'@'%' IDENTIFIED BY 'nav';

create database navms DEFAULT CHARACTER SET utf8;
create user 'navms'@'localhost' IDENTIFIED BY 'navms';
grant all on navms.* TO 'navms'@'%' IDENTIFIED BY 'navms';

create database hue DEFAULT CHARACTER SET utf8;
create user 'hue'@'localhost' IDENTIFIED BY 'hue';
grant all on hue.* to 'hue'@'localhost' identified by 'hue';

create database oozie;
create user 'oozie'@'localhost' IDENTIFIED BY 'oozie';
grant all privileges on oozie.* to 'oozie'@'localhost' identified by 'oozie';
grant all privileges on oozie.* to 'oozie'@'%' identified by 'oozie';

create database sqoop;
create user 'sqoop'@'localhost' IDENTIFIED BY 'sqoop';
grant all privileges on sqoop.* to 'sqoop'@'localhost' identified by 'sqoop';
grant all privileges on sqoop.* to 'sqoop'@'%' identified by 'sqoop';

_EOF

sleep 3
#Instalacion de java 1.7
sudo yum -y install java-1.7.0-openjdk

java -version

cp mysql-connector-java-5.1.42/mysql-connector-java-5.1.42-bin.jar /usr/share/java/mysql-connector-java.jar

sleep 1

sudo yum -y install cloudera-manager-daemons cloudera-manager-server

sudo yum -y install cloudera-manager-agent cloudera-manager-daemons

cd /usr/share/cmf/schema

./scm_prepare_database.sh mysql scm scm scm  

sleep 4

sudo service cloudera-scm-server enable

sleep 1

sudo service cloudera-scm-server start

sleep 1

sudo service cloudera-scm-server status

sleep 1

sudo service cloudera-scm-agent enable

sleep 1

sudo service cloudera-scm-agent-start




