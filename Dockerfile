FROM ubuntu:latest

RUN apt-get update --fix-missing
RUN apt-get install -y libkrb5-dev libc-client-dev git
RUN git clone git://github.com/php-build/php-build /tmp/php-build
WORKDIR /tmp/php-build
RUN ./install-dependencies.sh
RUN ./install.sh
# Latest stable and latest snapshot versions:
ENV PHP_BUILD_CONFIGURE_OPTS="--with-libxml --with-curl --with-zip --with-mysqli --with-pdo-mysql --enable-bcmath --enable-gd --enable-intl --enable-mbstring"
RUN php-build 7.4.13 /etc/php/7.4
# Other supported:
RUN php-build 8.0.0 /etc/php/8.0
RUN php-build 7.3.25 /etc/php/7.3
RUN php-build 7.2.33 /etc/php/7.2
RUN php-build 7.1.33 /etc/php/7.1

COPY switch-php-version /usr/local/bin/.
RUN switch-php-version 7.4
