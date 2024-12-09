ARG PHP_VERSION=8.3-fpm

FROM php:${PHP_VERSION} AS build

ARG COMPOSER_VERSION=2.7.7
ARG CODE_ROOT=.
ENV NODE_VERSION=18.16.1
ENV NVM_DIR=/usr/local/nvm
ENV ARTIFAKT_PHP_FPM_PORT=9000
ENV PHP_MEMORY_LIMIT=4G
ENV DEBUG=false
ENV MAGENTO_RUN_MODE=production
ENV UPLOAD_MAX_FILESIZE=64M
ENV PHP_EXTENSIONS="bcmath bz2 calendar exif gd gettext intl mysqli opcache pdo_mysql redis soap sockets sodium sysvmsg sysvsem sysvshm xsl zip pcntl apcu imagick"
ENV NODE_PATH="$NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules"
ENV PATH="$NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH"

# Install system dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  apt-utils \
  libbz2-dev \
  libfcgi-bin \
  libjpeg62-turbo-dev \
  libpng-dev \
  libfreetype6-dev \
  libgeoip-dev \
  libgmp-dev \
  libmagickwand-dev \
  libmagickcore-dev \
  libc-client-dev \
  libicu-dev \
  libpspell-dev \
  librecode0 \
  librecode-dev \
  libtidy-dev \
  libxslt1-dev \
  libyaml-dev \
  libzip-dev \
  lsof \
  default-mysql-client \
  sendmail \
  sendmail-bin \
  sudo \
  wget \
  zip \
  rsync \
  nano \
  unzip \
  htop \
  libpcre3-dev \
  libwebp-dev \
  libsodium-dev \
  git \
  && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN install-php-extensions $PHP_EXTENSIONS

# Install Composer
RUN curl -sS https://getcomposer.org/installer | \
  php -- --version=${COMPOSER_VERSION} --install-dir=/usr/local/bin --filename=composer
  
# Copy other configuration files
COPY ./etc/php-fpm.ini /usr/local/etc/php/conf.d/zzzz-magento.ini
COPY ./etc/mail.ini /usr/local/etc/php/conf.d/zzzz-mail.ini
COPY ./etc/opcache.exclusion /usr/local/etc/php/opcache.exclusion
COPY ./etc/php-fpm.conf /usr/local/etc/

# Substitute in php.ini values
ENV PHP_MEMORY_LIMIT=4G
ENV UPLOAD_MAX_FILESIZE=64M
RUN [ -n "${PHP_MEMORY_LIMIT}" ] && sed -i "s/_PHP_MEMORY_LIMIT_/${PHP_MEMORY_LIMIT}/" /usr/local/etc/php/conf.d/zzzz-magento.ini \
  && [ -n "${UPLOAD_MAX_FILESIZE}" ] && sed -i "s/_UPLOAD_MAX_FILESIZE_/${UPLOAD_MAX_FILESIZE}/" /usr/local/etc/php/conf.d/zzzz-magento.ini

# Install NVM and Node.js
RUN mkdir -p $NVM_DIR \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
  && /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use --delete-prefix $NODE_VERSION" \
  && mkdir -p /var/www/.nvm \
  && chown www-data:www-data /var/www/.nvm \
  && mkdir -p /var/www/.npm \
  && chown www-data:www-data /var/www/.npm \
  && mkdir -p /var/www/.config \
  && chown www-data:www-data /var/www/.config \
  && mkdir -p /var/www/.composer \
  && chown www-data:www-data /var/www/.composer

# Install Qualys agent
COPY ./QualysCloudAgent.deb /tmp/QualysCloudAgent.deb
RUN dpkg --install /tmp/QualysCloudAgent.deb || true

RUN mkdir /artifakt_scripts /artifakt_templates
COPY ./artifakt_scripts/* /artifakt_scripts/
COPY ./artifakt_templates/ /artifakt_templates/
RUN chmod -R +x /artifakt_scripts/

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
