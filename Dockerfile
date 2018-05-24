FROM ubuntu:16.04

MAINTAINER CuongPM<cuomgpm0503@gmail.com>

RUN DEBIAN_FRONTEND=noninteractive

RUN apt-get install -y nginx

RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections \
    && echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections \
    && apt-get install -y mysql-server

WORKDIR /venv

ADD deploy.sh /venv

RUN chmod a+x /venv/*

ENTRYPOINT ["/venv/deploy.sh"]

