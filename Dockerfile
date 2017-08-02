FROM php:7.1.7-fpm-alpine

RUN ln -fsn /usr/local/bin/php /usr/bin/php
RUN ln -fsn /usr/local/bin/php-config /usr/bin/php-config

ARG LIBRDKAFKA_GIT_SHA1=1f7417d4796e036b8c19f17373f8290ff5c7561f
RUN apk add --update --no-cache alpine-sdk bash python autoconf && \
  git clone -o ${LIBRDKAFKA_GIT_SHA1} https://github.com/edenhill/librdkafka.git /tmp/librdkafka && \
  cd /tmp/librdkafka/ && \
  ./configure && \
  make && \
  make install

# php-rdkafka should be compiled using the same php module as result we are passing
# --with-php-config /usr/local/bin/php-config
ARG PHPCONF_PATH=/usr/local/etc/php/conf.d
ARG RDKAFKA_PHP_GIT_SHA1=abd6b6add8e0b983c27245a59981a9a4b5389139
RUN apk add --update --no-cache pcre-dev && \
  pecl install rdkafka && \
  echo "extension=rdkafka.so" > ${PHPCONF_PATH}/rdkafka.ini

COPY templates/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY templates/www.conf /usr/local/etc/php-fpm.d/www.conf
