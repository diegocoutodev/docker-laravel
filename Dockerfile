FROM alpine:latest
LABEL MAINTAINER="Diego do Couto <eng.coutodiego@gmail.com>"

# add our user and group first to make sure their IDs gets assigned consistently
RUN addgroup -S -g 1000 laravel && adduser -S -G laravel -u 999 laravel

ENV PHP_VERSION 7

ENV DEPS="php${PHP_VERSION} \ 
    php${PHP_VERSION}-pdo \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-pdo_pgsql \
    php${PHP_VERSION}-pdo_mysql \
    php${PHP_VERSION}-mcrypt \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-gd\
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-openssl \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-phar \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-tokenizer\ 
    php${PHP_VERSION}-session \
    php${PHP_VERSION}-zlib\
    php${PHP_VERSION}-fileinfo\
    php${PHP_VERSION}-xmlwriter"

RUN apk add --no-cache --update \
    tzdata ${DEPS}

# Installing composer
RUN php${PHP_VERSION} -r "copy('http://getcomposer.org/installer', 'composer-setup.php');" && \
    php${PHP_VERSION} composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php${PHP_VERSION} -r "unlink('composer-setup.php');" && \
    ln -s /etc/php${PHP_VERSION}/php.ini /etc/php${PHP_VERSION}/conf.d/php.ini && \
    mkdir -p /.composer /laravel/app && chown -Rf laravel. /.composer && \
    chown -Rf laravel. /laravel 

ADD uid_entrypoint /usr/bin

USER laravel

# Installing global Laravel installer
RUN composer global require laravel/installer

WORKDIR /laravel/app

VOLUME [ "/laravel/app", "/.composer" ]

ENTRYPOINT [ "/usr/bin/uid_entrypoint" ]
