FROM ubuntu:latest

# Prevent some error messages
ENV DEBIAN_FRONTEND noninteractive

# Install latest updates and mysql
RUN apt-get update;apt-get upgrade -y; apt-get -y install vim apache2 supervisor wget curl php5 php5-mysql php5-gd php5-cli php5-curl php-apc git mysql-client mysql-server php5-dev php-pear php5-dev php5-intl php5-xsl openssh-client php5-mcrypt openjdk-7-jre  imagemagick

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
RUN sed -i 's/memory_limit = 128M/memory_limit = 2048M/g' /etc/php5/apache2/php.ini
RUN a2enmod rewrite
RUN a2enmod headers

ADD start.sh /usr/local/bin/start.sh
RUN chmod -v +x /usr/local/bin/start.sh

ADD supervisord.conf /etc/supervisord.conf

# Set Standard settings
ENV user admin
ENV password admin
ENV right WRITE

EXPOSE 80 3306

CMD ["/usr/local/bin/start.sh"]
