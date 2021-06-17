FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

# cd /usr/local/runme
WORKDIR /usr/local/runme

ARG SQL_SCRIPT=./db/010_init.sql
ARG NEXTCLOUD_CONFIG=./nextcloud.conf

# copy to working directory
COPY ${SQL_SCRIPT} /usr/local/runme/010_init.sql

RUN apt-get update;
RUN apt-get install -y apache2 php wget nano;

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# copy new configuration
COPY ${NEXTCLOUD_CONFIG} /etc/apache2/sites-available/nextcloud.conf
RUN ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/nextcloud.conf

RUN apt-get install -y php7.4-gd php7.4-json php7.4-mysql php7.4-curl php7.4-mbstring php-intl php-imagick php7.4-xml php7.4-zip

RUN apt-get install -y mariadb-server systemctl
RUN a2enmod rewrite
RUN a2enmod headers
RUN wget https://download.nextcloud.com/server/releases/nextcloud-19.0.7.tar.bz2
RUN tar xjf nextcloud-19.0.7.tar.bz2
RUN cp -r nextcloud /var/www/
RUN chown -R www-data:www-data /var/www/nextcloud/ 

ENTRYPOINT /etc/init.d/apache2 start && /etc/init.d/mysql start && bash


	


