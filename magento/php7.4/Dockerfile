ARG PHP_VERSION=7.4-fpm

FROM php:${PHP_VERSION}

LABEL vendor="HSFDigital" \
  author="digital@henryschein.fr" \
  stage="alpha"

ARG ARTIFAKT_COMPOSER_VERSION=2.2.5
ARG CODE_ROOT=.
ARG NEWRELIC_VERSION=10.11.0.3
ENV NODE_VERSION=18.16.1
ENV NVM_DIR /usr/local/nvm
ENV ARTIFAKT_PHP_FPM_PORT=9000
ENV PHP_MEMORY_LIMIT 4G
ENV DEBUG false
ENV MAGENTO_RUN_MODE production
ENV UPLOAD_MAX_FILESIZE 64M
ENV PHP_EXTENSIONS bcmath bz2 calendar exif gd gettext intl mysqli opcache pdo_mysql redis soap sockets sodium sysvmsg sysvsem sysvshm xsl zip pcntl

# Install dependencies
# hadolint ignore=DL3008
RUN \
  --mount=type=cache,target=/var/cache/apt \
  apt-get update \
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
  libkrb5-dev \
  libicu-dev \
  libldap2-dev \
  libpspell-dev \
  librecode0 \
  librecode-dev \
  libtidy-dev \
  libxslt1-dev \
  libyaml-dev \
  libzip-dev \
  lsof \
  mariadb-client \
  sendmail \
  sendmail-bin \
  sudo \
  wget \
  zip \
  rsync \
  parallel \
  nano \
  unzip \
  htop \
  && rm -rf /var/lib/apt/lists/*

# Configure the gd library
RUN docker-php-ext-configure \
  gd --with-freetype --with-jpeg
RUN docker-php-ext-configure \
  imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-configure \
  ldap --with-libdir=lib/$(uname -m)-linux-gnu
RUN docker-php-ext-configure \
  opcache --enable-opcache
RUN docker-php-ext-configure zip

# Install required PHP extensions
# hadolint ignore=SC2046
RUN docker-php-ext-install -j$(nproc) \
  bcmath \
  bz2 \
  calendar \
  exif \
  gd \
  gettext \
  gmp \
  imap \
  intl \
  ldap \
  mysqli \
  opcache \
  pdo_mysql \
  pspell \
  shmop \
  soap \
  sockets \
  sysvmsg \
  sysvsem \
  sysvshm \
  tidy \
  xmlrpc \
  xsl \
  zip \
  pcntl

RUN pecl install -o -f \
  geoip-1.1.1 \
  igbinary \
  imagick \
  mailparse \
  msgpack \
  oauth \
  propro \
  raphf \
  redis \
  yaml

# hadolint ignore=DL3003,DL4006,SC2039
RUN rm -f /usr/local/etc/php/conf.d/*sodium.ini \
  && rm -f /usr/local/lib/php/extensions/*/*sodium.so \
  && apt-get remove libsodium* -y  \
  && mkdir -p /tmp/libsodium  \
  && curl -sL https://github.com/jedisct1/libsodium/archive/1.0.18-RELEASE.tar.gz | tar xzf - -C  /tmp/libsodium \
  && cd /tmp/libsodium/libsodium-1.0.18-RELEASE/ \
  && ./configure \
  && make && make check \
  && make install  \
  && cd / \
  && rm -rf /tmp/libsodium  \
  && pecl install -o -f libsodium

RUN docker-php-ext-enable \
  bcmath \
  bz2 \
  calendar \
  exif \
  gd \
  geoip \
  gettext \
  gmp \
  igbinary \
  imagick \
  imap \
  intl \
  ldap \
  mailparse \
  msgpack \
  mysqli \
  oauth \
  opcache \
  pdo_mysql \
  propro \
  pspell \
  raphf \
  redis \
  shmop \
  soap \
  sockets \
  sodium \
  sysvmsg \
  sysvsem \
  sysvshm \
  tidy \
  xmlrpc \
  xsl \
  yaml \
  zip \
  pcntl

RUN curl -sS https://getcomposer.org/installer | \
  php -- --version=${ARTIFAKT_COMPOSER_VERSION} --install-dir=/usr/local/bin --filename=composer

# hadolint ignore=DL3022
COPY --from=mysql:8 /usr/bin/my* /usr/bin/

COPY ./etc/php-fpm.ini /usr/local/etc/php/conf.d/zzzz-magento.ini
COPY ./etc/mail.ini /usr/local/etc/php/conf.d/zzzz-mail.ini
COPY ./etc/opcache.exclusion /usr/local/etc/php/opcache.exclusion

# Substitute in php.ini values
RUN [ -n "${PHP_MEMORY_LIMIT}" ] && sed -i "s/_PHP_MEMORY_LIMIT_/${PHP_MEMORY_LIMIT}/" /usr/local/etc/php/conf.d/zzzz-magento.ini
RUN [ -n "${UPLOAD_MAX_FILESIZE}" ] && sed -i "s/_UPLOAD_MAX_FILESIZE_/${UPLOAD_MAX_FILESIZE}/" /usr/local/etc/php/conf.d/zzzz-magento.ini

COPY ./etc/php-fpm.conf /usr/local/etc/

RUN mkdir /artifakt_scripts /artifakt_templates
COPY ./artifakt_scripts/* /artifakt_scripts/
COPY ./artifakt_templates/ /artifakt_templates/
RUN chmod -R +x /artifakt_scripts/

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Run node install.sh
RUN mkdir -p $NVM_DIR
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use --delete-prefix $NODE_VERSION"
ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH
RUN mkdir /var/www/.nvm && chown www-data:www-data /var/www/.nvm && \
        mkdir /var/www/.npm && chown www-data:www-data /var/www/.npm && \
        mkdir /var/www/.config && chown www-data:www-data /var/www/.config

#Install NewRelic
RUN \
  curl -L https://download.newrelic.com/php_agent/archive/${NEWRELIC_VERSION}/newrelic-php5-${NEWRELIC_VERSION}-linux.tar.gz | tar -C /tmp -zx && \
  export NR_INSTALL_USE_CP_NOT_LN=1 && \
  export NR_INSTALL_SILENT=1 && \
  /tmp/newrelic-php5-*/newrelic-install install && \
  rm -rf /tmp/newrelic-php5-* /tmp/nrinstall*

# Install qualys agent
RUN dpkg --install ./QualysCloudAgent.deb || true
