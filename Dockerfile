FROM php:7.2-fpm-alpine
MAINTAINER XM <xm@tqzgc.com>

RUN set -xe; \
  # set repository & timezone
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && apk add --no-cache tzdata && cp  /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && apk del --no-cache --no-network tzdata \
  # install deps, after install these can be removed
  && apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    # some exts depended on, such as gd(with with-zlib arg),
    zlib-dev \
    # gd ext
    freetype-dev libwebp-dev jpeg-dev libpng-dev \
    # bz2 ext
    bzip2-dev \
    # intl ext
    icu-dev \
    # gettext ext
    gettext-dev \
  # install packages
  && apk add \
    # gd ext
    libpng libjpeg libwebp freetype \
    # intl icu
    icu \
    # gettext ext
    gettext \
  # install some extra common exts: bc_math, exif, mysqli, pdo_mysql, pcntl, shmop, sockets, zip
  && docker-php-ext-install -j$(nproc) bcmath exif mysqli pdo_mysql pcntl shmop sockets zip \
  # install gd
  && docker-php-ext-configure gd --with-freetype-dir --with-jpeg-dir --with-png-dir --with-webp-dir --with-zlib-dir \
  && docker-php-ext-install -j$(nproc) gd \
  # install bz2
  && docker-php-ext-install -j$(nproc) bz2 \
  # install intl
  && docker-php-ext-install -j$(nproc) intl \
  # install gettext
  && docker-php-ext-install -j$(nproc) gettext \
  # enable opacache.so
  && docker-php-ext-enable opcache \
  # install redis
  # auto anwser these two question: enable igbinary serializer support? [no] ,enable lzf compression support? [no] : yes
  # if enable igbinary : `pecl install igbinary && docker-php-ext-enable igbinary`(same as add "extension=igbinary.so" to php.ini)
  && pecl install igbinary && docker-php-ext-enable igbinary \
  && echo -e "yes\nyes" | pecl install redis && docker-php-ext-enable redis \
  # install xdebug
  && pecl install xdebug && docker-php-ext-enable xdebug \
  && apk del --no-cache --no-network .build-deps \
  # delete extracted php src
  && docker-php-source delete
