FROM alpine:latest
LABEL MAINTAINER="Diego do Couto <eng.coutodiego@gmail.com>"

ENV LARAVEL_UID=1000 \
    LARAVEL_GID=1000

# add our user and group first to make sure their IDs gets assigned consistently
RUN addgroup -S -g ${LARAVEL_GID} laravel && adduser -S -G laravel -u ${LARAVEL_UID} laravel

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
    mkdir -p /.composer /laravel/app && chown -Rf ${LARAVEL_UID}:${LARAVEL_GID} /.composer && \
    chown -Rf ${LARAVEL_UID}:${LARAVEL_GID} /laravel

RUN mkdir -p /home/laravel/.config/psysh/ && \
    touch /home/laravel/.config/psysh/psysh_history &&\
    chown -Rf ${LARAVEL_UID}:${LARAVEL_GID} /home/laravel/.config/psysh/psysh_history

ADD docker-entrypoint.sh /usr/bin
RUN chmod a+x /usr/bin/docker-entrypoint.sh

USER ${LARAVEL_UID}

ENV HOME /home/laravel

# Installing global Laravel installer
RUN composer global require laravel/installer

WORKDIR /laravel/app

### /home/laravel/.config is tinker's directory 
VOLUME [ "/laravel/app", "/.composer", "/home/laravel/.config" ]

ENTRYPOINT [ "/usr/bin/docker-entrypoint.sh" ]
