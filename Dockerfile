# from https://www.drupal.org/requirements/php#drupalversions
FROM php:7.1-fpm

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

## Install Git
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install git -y

# Install Mysql Client package for Drush compatibility.
RUN apt-get install mysql-client -y

# Install text editor.
RUN apt-get install vim -y

WORKDIR /code

# Add lines to .bashrc for CLI improvments.
RUN echo "export PATH=$PATH:/code/vendor/bin" >> ~/.bashrc
RUN echo "alias ll='ls -la'" >> ~/.bashrc