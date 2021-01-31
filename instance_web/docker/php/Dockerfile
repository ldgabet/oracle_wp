FROM php:7.4-fpm

ARG uid
ARG gid

# Install aditional extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions \
    && sync && install-php-extensions \
    gd \
    intl \
    soap \
    exif \
    gettext \
    mysqli \
    calendar \
    opcache \
    sockets \
    imagick \
    memcached \
    zip

RUN apt-get update && apt-get install --no-install-recommends --yes \
    # Install mail agent
    ca-certificates msmtp \

    # To clean after install
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create user and group 'www-data'
RUN if [ ${uid:-0} -ne 0 ] && [ ${gid:-0} -ne 0 ]; then \
        deluser www-data \
        && if getent group www-data ; then delgroup www-data; fi \
        && addgroup --gid ${gid} --system www-data \
        && adduser --uid ${uid} --disabled-login --system --group www-data; \
    fi

# Use 'www-data' instead of 'root'
USER www-data