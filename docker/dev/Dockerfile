FROM docker.n-educatio.pl/php:8.0-apache2.4

LABEL maintainer="Michał Prył <mpryl@n-educatio.pl>" \
      description="PHP dev image" \
      version="1.0"

ARG USER_ID=1000
ARG GROUP_ID=1000

ENV TERMINFO=/opt/share/terminfo \
    TERM=xterm \
    PHP_COMMAND=/usr/bin/php \
    DEST_USER=docker-user \
    USER_ID=$USER_ID \
    GROUP_ID=$GROUP_ID \
    DEBIAN_FRONTEND=noninteractive

ENV BUILD_DEPS \
  wget \
  curl \
  autoconf \
  build-essential

RUN set -eux; \
    apt-get update && apt-get install -y \
    $BUILD_DEPS \
    $PHPIZE_DEPS \
    sed \
    tar \
    htop \
    nano \
    git \
    libzip-dev \
    libpq-dev \
    unzip \
    netcat; \
    docker-php-ext-configure.sh pgsql -with-pgsql=/usr/local/pgsql; \
    docker-php-ext-install.sh pdo pdo_pgsql pgsql zip intl; \
    printf "\n" | pecl install xdebug apcu && \
    docker-php-ext-enable.sh xdebug apcu; \
    mkdir -p /usr/local/bin && \
    wget https://get.symfony.com/cli/installer -O - | bash && \
    mv /root/.symfony/bin/symfony /usr/local/bin/symfony && \
    chmod a+x /usr/local/bin/symfony; \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - ; \
    echo "deb https://deb.nodesource.com/node_14.x focal main" | tee /etc/apt/sources.list.d/nodesource.list; \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - ; \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list; \
    apt-get update && apt-get install -y nodejs yarn; \
    yarn global add jshint --prefix /usr/local; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPS $PHPIZE_DEPS;

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

RUN a2enmod rewrite

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && sed -i 's/memory_limit = .*/memory_limit = -1/' /usr/local/etc/php/php.ini \
    && echo "date.timezone = Europe/Warsaw" >> /usr/local/etc/php/php.ini \
    && echo "upload_max_filesize = 20M" >> /usr/local/etc/php/php.ini \
    && echo "post_max_size = 21M" >> /usr/local/etc/php/php.ini \
    && echo "short_open_tag = Off" >> /usr/local/etc/php/php.ini

RUN rm -v /etc/apache2/sites-available/000-default.conf
COPY site.conf /etc/apache2/sites-available/000-default.conf
COPY dev/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create default user
RUN /bin/bash -c "source /createDockerUser.sh && createDefaultDockerUser ${USER_ID} ${GROUP_ID}"

# Create Jenkins user
RUN /bin/bash -c "source /createDockerUser.sh && createUser \"jenkins\" 112 \"jenkins\" 118"

RUN mkdir -p /project/public
RUN ln -s /project/public /var/www/project

EXPOSE 80

WORKDIR /project

CMD ["/entrypoint.sh"]
