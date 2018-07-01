FROM nginx:latest
ARG UID=33
ARG GID=33

RUN usermod -u $UID www-data \
    && groupmod -g $GID www-data

