FROM centos:7

LABEL maintainer="matt.cho@gmx.com"

# As instructed in https://hub.docker.com/_/centos/
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
  systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*;\
  rm -f /etc/systemd/system/*.wants/*;\
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*;\
  rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

# Remi repo
RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm

# Dev tools: c/c++ compilers, gcc, and make, etc.
# RUN yum -y groupinstall 'Development Tools'
RUN yum -y install gcc make libaio libpng-devel systemtap-sdt-devel

# Node
RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
RUN yum -y install nodejs

# Utils: vim, unzip, etc.
RUN yum -y install vim, unzip

# Apache
RUN yum -y install httpd
COPY ./app-httpd.conf /etc/httpd/conf.d/app-httpd.conf

# Set the default directory
WORKDIR /var/www/app
# ADD ./phpinfo.php /var/www/app

# PHP 7.1
RUN yum -y install yum-utils
RUN yum-config-manager --enable remi-php71
RUN yum -y install php php-pear php-devel
RUN yum -y install php-mbstring php-pgsql

# Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Copy OCI8 Oracle libraries
RUN mkdir -p /opt/oracle/
COPY ./oracle/instantclient-basiclite-linux.x64-12.2.0.1.0.zip /opt/oracle/
COPY ./oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip /opt/oracle/
COPY ./oracle/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip /opt/oracle/

# OCI8
RUN pear upgrade pear
RUN unzip /opt/oracle/instantclient-basiclite-linux.x64-12.2.0.1.0.zip -d /opt/oracle
RUN unzip /opt/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /opt/oracle
RUN unzip /opt/oracle/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -d /opt/oracle
RUN ls /opt/oracle
RUN ln -s /opt/oracle/instantclient_12_2 /opt/oracle/instantclient
RUN ln -sf /opt/oracle/instantclient/libclntsh.so.12.1 /opt/oracle/instantclient/libclntsh.so
RUN ln -sf /opt/oracle/instantclient/libocci.so.12.1 /opt/oracle/instantclient/libocci.so
ENV PHP_DTRACE=yes
RUN echo 'instantclient,/opt/oracle/instantclient' | pecl install oci8
RUN echo "extension=oci8.so" > /etc/php.d/oci8.ini;

# Clean up
RUN yum clean all

# Start Apache
RUN systemctl enable httpd.service

EXPOSE 80

CMD ["/usr/sbin/init"]