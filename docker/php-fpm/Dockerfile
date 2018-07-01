FROM php:7.2-fpm
ARG PHP_EXTENSIONS
ARG PHP_DEPENDENCIES
ARG UID=33
ARG GID=33

RUN apt-get update \
    && apt-get install -y $PHP_DEPENDENCIES \
    && docker-php-ext-install $PHP_EXTENSIONS \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN usermod -u $UID www-data \ 
    && groupmod -g $GID www-data
