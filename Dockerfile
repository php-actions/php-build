FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y git
RUN git clone git://github.com/php-build/php-build /tmp/php-build
WORKDIR /tmp/php-build
RUN ./install-dependencies.sh
RUN ./install.sh
# Latest stable and latest snapshot versions:
RUN php-build 7.4.10 /etc/php/7.4
RUN php-build 8.0snapshot /etc/php/8.0
# Previous supported:
RUN php-build 7.3.22 /etc/php/7.3
RUN php-build 7.2.33 /etc/php/7.2
RUN php-build 7.1.33 /etc/php/7.1

COPY switch-php-version /usr/local/bin/.
RUN switch-php-version 7.4
