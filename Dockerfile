FROM php:8.2-apache-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libcurl4-openssl-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libldap2-dev \
        libonig-dev \
        libpng-dev \
        libxml2-dev \
        libzip-dev \
        unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install -j"$(nproc)" curl exif gd intl ldap mbstring opcache pdo_mysql xml zip \
    && a2enmod deflate expires headers rewrite \
    && rm -rf /var/lib/apt/lists/*

COPY docker/php.ini /usr/local/etc/php/conf.d/humhub.ini

WORKDIR /var/www/html
COPY . /var/www/html

RUN if [ ! -f .htaccess ]; then cp .htaccess.dist .htaccess; fi \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R u+rwX,g+rwX assets uploads protected/runtime protected/config protected/modules themes

EXPOSE 80
