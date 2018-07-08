FROM php:7.1-fpm
ARG PHP_EXTENSIONS
ARG PHP_DEPENDENCIES
ARG PECL_EXTENSIONS
ARG UID=33
ARG GID=33

RUN apt-get update \
    && apt-get install -y $PHP_DEPENDENCIES \
    && docker-php-ext-install $PHP_EXTENSIONS \
    && if [ ! -z "$PECL_EXTENSIONS" ]; then pecl install $PECL_EXTENSIONS; fi \
    && if [ ! -z "$PECL_EXTENSIONS" ]; then docker-php-ext-enable $(echo $PECL_EXTENSIONS | grep -oP '(?:[a-z][a-z0-9_]*)' | tr '\n' ' '); fi \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN usermod -u $UID www-data \ 
    && groupmod -g $GID www-data
