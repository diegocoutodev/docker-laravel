#!/bin/sh

export PATH=$PATH:/home/laravel/.composer/vendor/bin

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${laravel:-default}:x:$(id -u):0:${laravel:-default} user:/home/laravel:/sbin/nologin" >> /etc/passwd
  fi
fi

exec "$@"
