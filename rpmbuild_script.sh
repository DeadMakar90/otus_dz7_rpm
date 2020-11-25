#!/bin/bash
sudo yum groupinstall -y "Development Tools" 
sudo yum install -y wget createrepo yum-utils gnutls-devel
cd /root
sudo wget https://repo.zabbix.com/zabbix/3.0/rhel/7/SRPMS/zabbix-3.0.31-1.el7.src.rpm
sudo wget https://repo.zabbix.com/non-supported/rhel/7/x86_64/iksemel-1.4-2.el7.centos.x86_64.rpm
sudo wget https://repo.zabbix.com/non-supported/rhel/7/x86_64/iksemel-devel-1.4-2.el7.centos.x86_64.rpm
sudo wget https://repo.zabbix.com/non-supported/rhel/7/x86_64/iksemel-utils-1.4-2.el7.centos.x86_64.rpm
sudo rpm -i *64.rpm
sudo rpm -i zabbix-3.0.31-1.el7.src.rpm
sudo yum-builddep -y /root/rpmbuild/SPECS/zabbix.spec
sudo rpmbuild -bb /root/rpmbuild/SPECS/zabbix.spec
sudo yum install localinstall -y /root/rpmbuild/RPMS/x86_64/zabbix-agent-3.0.31-1.el7.x86_64.rpm

#Создание репозитория
sudo yum install -y epel-release
sudo yum install -y nginx
sudo systemctl enable nginx
sudo mkdir /usr/share/nginx/html/repo
sudo cp /root/rpmbuild/RPMS/x86_64/zabbix*.rpm /usr/share/nginx/html/repo
sudo createrepo /usr/share/nginx/html/repo/
sudo createrepo --update /usr/share/nginx/html/repo
sudo touch /etc/yum.repos.d/zabbixotus.repo
echo -e "[zabbixotus]\nname=zabbixotus\nbaseurl=http://localhost/repo\ngpgcheck=0\nenabled=1" | sudo tee -a /etc/yum.repos.d/zabbixotus.repo
sudo systemctl start nginx
