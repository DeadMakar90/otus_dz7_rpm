# Домашнее задание. Управление пакетами. Дистрибьюция софта

## Домашнее задание

    Размещаем свой RPM в своем репозитории
    Цель: Часто в задачи администратора входит не только установка пакетов, но и сборка и поддержка собственного репозитория. Этим и займемся в ДЗ.
    1) создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями)
    2) создать свой репо и разместить там свой RPM
    реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо 

    * реализовать дополнительно пакет через docker
    Критерии оценки: 5 - есть репо и рпм
    +1 - сделан еще и докер образ
    
    
#### 1. Сборка RPM Zabbix версии 3.0.31:

Выполнить установку необходимых для сборки пакетов:

```
sudo yum groupinstall -y "Development Tools"
sudo yum install -y wget createrepo yum-utils gnutls-devel
```

Выполнить загрузку исходников:
```
cd /root
sudo wget https://repo.zabbix.com/zabbix/3.0/rhel/7/SRPMS/zabbix-3.0.31-1.el7.src.rpm
sudo wget https://repo.zabbix.com/non-supported/rhel/7/x86_64/iksemel-1.4-2.el7.centos.x86_64.rpm
sudo wget https://repo.zabbix.com/non-supported/rhel/7/x86_64/iksemel-devel-1.4-2.el7.centos.x86_64.rpm
sudo wget https://repo.zabbix.com/non-supported/rhel/7/x86_64/iksemel-utils-1.4-2.el7.centos.x86_64.rpm
```
Произвести установку скачанных пакетов:
```
sudo rpm -i *64.rpm
sudo rpm -i zabbix-3.0.31-1.el7.src.rpm
```
Доустановить необходимые зависимости:
```
sudo yum-builddep -y /root/rpmbuild/SPECS/zabbix.spec
```
Выполнить сборку пакета:
```
sudo rpmbuild -bb /root/rpmbuild/SPECS/zabbix.spec
```
Произвести установку одного из собранных пакетов:
```
sudo yum install localinstall -y /root/rpmbuild/RPMS/x86_64/zabbix-agent-3.0.31-1.el7.x86_64.rpm
```
Запустить zabbix-agent:
```
sudo systemctl start zabbix-agent.service
```
Посмотреть с какими параметрами был скомпилирован zabbix:
```
[vagrant@localhost ~]$ zabbix_agentd -V
zabbix_agentd (daemon) (Zabbix) 3.0.31
Revision 3e15255cda 27 April 2020, compilation time: Nov 25 2020 21:49:59

Copyright (C) 2020 Zabbix SIA
License GPLv2+: GNU GPL version 2 or later http://gnu.org/licenses/gpl.html.
This is free software: you are free to change and redistribute it according to
the license. There is NO WARRANTY, to the extent permitted by law.

This product includes software developed by the OpenSSL Project
for use in the OpenSSL Toolkit (http://www.openssl.org/).

Compiled with OpenSSL 1.0.2k-fips  26 Jan 2017
Running with OpenSSL 1.0.2k-fips  26 Jan 2017
```

#### 2. Создать свой репозиторий

Выполнить установку пакетов:
```
sudo yum install -y epel-release
sudo yum install -y nginx
sudo systemctl enable nginx
```

Создать папку с будущим репозиторием:
```
sudo mkdir /usr/share/nginx/html/repo
```
Скопировать скомпилированные пакеты:
```
sudo cp /root/rpmbuild/RPMS/x86_64/zabbix*.rpm /usr/share/nginx/html/repo
```
Создать репозиторий:
```
sudo createrepo /usr/share/nginx/html/repo/
sudo createrepo --update /usr/share/nginx/html/repo
```
Чтобы протестировать созданный репозиторий необходимо создать файл и привести его к виду:
```
sudo touch /etc/yum.repos.d/zabbixotus.repo
echo -e "[zabbixotus]\nname=zabbixotus\nbaseurl=http://localhost/repo\ngpgcheck=0\nenabled=1" | sudo tee -a /etc/yum.repos.d/zabbixotus.repo
```
Запустить сервис nginx:
```
sudo systemctl start nginx
```

Посмотреть подключенный репозиторий:
```
[vagrant@localhost ~]$ yum list | grep zabbixotus
zabbix-debuginfo.x86_64                   3.0.31-1.el7                 zabbixotus
zabbix-get.x86_64                         3.0.31-1.el7                 zabbixotus
zabbix-java-gateway.x86_64                3.0.31-1.el7                 zabbixotus
zabbix-proxy-mysql.x86_64                 3.0.31-1.el7                 zabbixotus
zabbix-proxy-pgsql.x86_64                 3.0.31-1.el7                 zabbixotus
zabbix-proxy-sqlite3.x86_64               3.0.31-1.el7                 zabbixotus
zabbix-sender.x86_64                      3.0.31-1.el7                 zabbixotus
zabbix-server-mysql.x86_64                3.0.31-1.el7                 zabbixotus
zabbix-server-pgsql.x86_64                3.0.31-1.el7                 zabbixotus
```

#### 3. Реализовать пакет через docker:

Установить репозиторий, для этого загрузить файл с настройками репозитория:
```
sudo wget https://download.docker.com/linux/centos/docker-ce.repo
sudo mv docker-ce.repo /etc/yum.repos.d/
```
Установить docker:
```
sudo yum install docker-ce docker-ce-cli containerd.io
```
Запустить сервис:
```
systemctl enable docker
systemctl start docker
```
Чтобы создать образ, необходимо создать каталог для размещения Dockerfile и создать его:
```
sudo mkdir -p /opt/docker/mynginx
sudo vi Dockerfile
```
Мы будем собирать nginx, для этого, Dockerfile должен иметь вид:
```
FROM centos:7
MAINTAINER KunakbaevVV vkunakbaev@1111.ru
RUN yum install -y redhat-lsb-core wget rpmdevtools rpm-build yum-utils openssl-devel zlib-devel pcre-devel gcc libtool perl-core openssl
RUN wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
RUN rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
RUN yum-builddep -y /root/rpmbuild/SPECS/nginx.spec
RUN rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
RUN yum localinstall -y /root/rpmbuild/RPMS/x86_64/*.rpm
RUN yum clean all
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i "0,/nginx/s/nginx/docker-nginx/i" /usr/share/nginx/html/index.html
CMD [ "nginx" ]
```
Запустить сборку:
```
sudo docker build -t vkunakbaev/nginx:v1 .
.........
Successfully built eae801eaeff2
Successfully tagged vkunakbaev/nginx:v1
```

Посмотреть список образов можно командой:
```
docker images
```

Создать и запустить контейнер из образа:
```
docker run -d -p 8080:80 vkunakbaev/nginx:v1
```
Загрузка образа на Docker Hub:

1. Зарегистрироваться на Docker Hub по ссылке: https://hub.docker.com/signup?next=%2F%3Fref%3Dlogin

2. Перейти на страницу Repositories и создать свой репозиторий, в нашем случае, vkunakbaev. Теперь можно загрузить образ в репозиторий.

3. Авторизоваться на машине с образом под зарегистрированным пользователем:
```
docker login --username vkunakbaev
```
4. Задать тег для одного из образов и загрузить его в репозиторий:
```
docker tag vkunakbaev/nginx:v1 kunakow/otus:otus

docker push kunakow/otus:otus
```
В Docker Hub должны появиться наш образы.

Чтобы воспользоваться образом на другом компьютере, необходимо авторизоваться под зарегистрированным пользователем:
```
sudo docker login --username kunakow
```
Загрузить образ:
```
docker pull kunakow/otus:otus
```
Запустить:
```
docker run -d -p 8080:80 kunakow/otus:otus
```
