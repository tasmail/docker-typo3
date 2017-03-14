FROM php:7.0-apache

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y \
	wget \
	libjpeg-dev \
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libpng12-dev \
	libxml2-dev \
	libltdl7-dev \
	libmcrypt-dev \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr; \
    docker-php-ext-install gd mysqli opcache zip soap mcrypt

RUN apt-get update && apt-get install -y libmagickwand-6.q16-dev --no-install-recommends \
&& ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin \
&& pecl install imagick \
&& echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini

RUN { \
	echo 'opcache.memory_consumption=128'; \
	echo 'opcache.interned_strings_buffer=8'; \
	echo 'opcache.max_accelerated_files=4000'; \
	echo 'opcache.revalidate_freq=2'; \
	echo 'opcache.fast_shutdown=1'; \
	echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini


RUN { \
	echo 'always_populate_raw_post_data = -1'; \
	echo 'max_execution_time = 240'; \
	echo 'max_input_vars = 1500'; \
	echo 'upload_max_filesize = 32M'; \
	echo 'post_max_size = 32M'; \
    } > /usr/local/etc/php/conf.d/typo3.ini

VOLUME /var/www/html

ENV TYPO3_VERSION "7.6.16"
ENV TYPO3_MD5_CHECKSUM "7fffa86463ab7e0a84d003afbed0c882"

RUN set -ex; \
    wget  https://get.typo3.org/${TYPO3_VERSION} -O typo3.tar.gz; \
    echo "$TYPO3_MD5_CHECKSUM *typo3.tar.gz" | md5sum -c -; \
    tar -xzf typo3.tar.gz -C /var/www/html; \
    rm typo3.tar.gz; \
    cd /var/www/html; \
    ln -s typo3_src-* typo3_src; \
    ln -s typo3_src/index.php; \
    ln -s typo3_src/typo3; \
    ln -s _.htaccess .htaccess; \
    mkdir typo3temp; \
    mkdir typo3conf; \
    mkdir fileadmin; \
    mkdir uploads; \
    touch FIRST_INSTALL; \
    chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html
