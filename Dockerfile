# from https://www.drupal.org/requirements/php#drupalversions
FROM php:7.0-fpm

# install the PHP extensions we need
RUN set -ex \
	&& buildDeps=' \
		libjpeg62-turbo-dev \
		libpng12-dev \
		libpq-dev \
	' \
	&& apt-get update && apt-get install -y --no-install-recommends $buildDeps && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
	&& docker-php-ext-install -j "$(nproc)" gd mbstring opcache pdo pdo_mysql zip \
	&& apt-mark manual \
		libjpeg62-turbo \
		libpq5 \
	&& apt-get purge -y --auto-remove $buildDeps

## Enable XDebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

WORKDIR $HOME

# installing composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm composer-setup.php

# installing Drupal Console
RUN php -r "copy('https://drupalconsole.com/installer', 'drupal.phar');"
RUN mv drupal.phar /usr/local/bin/drupal
RUN chmod +x /usr/local/bin/drupal
RUN drupal init
RUN drupal self-update

WORKDIR /var/www/html