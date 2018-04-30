FROM fedora:27

LABEL maintainer="matt.cho@gmx.com"

# Dev tools
RUN yum -y install gcc gcc-c++ make libaio libpng-devel systemtap-sdt-devel

# Node
RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
RUN yum -y install nodejs

# Utils: vim, unzip, etc.
RUN yum -y install vim unzip

# Apache
RUN yum -y install httpd
COPY ./app-httpd.conf /etc/httpd/conf.d/app-httpd.conf

# Set the default directory
WORKDIR /var/www/app
ADD ./phpinfo.php /var/www/app

# PHP 7.1
# RUN yum -y install yum-utils
# RUN yum-config-manager --enable remi-php71
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