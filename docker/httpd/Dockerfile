FROM httpd:latest
ARG UID=33
ARG GID=33

RUN usermod -u $UID www-data \
    && groupmod -g $GID www-data \
    && echo "IncludeOptional conf.d/*.conf" >> /usr/local/apache2/conf/httpd.conf
