FROM centos:7
MAINTAINER KunakbaevVV vkunakbaev@astralinux.ru
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
