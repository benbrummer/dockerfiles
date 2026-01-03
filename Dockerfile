ARG PHP_VERSION=8.4
ARG FRANKENPHP_VERSION=1
ARG DEBIAN_VERSION=trixie

FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION}-${DEBIAN_VERSION} AS prepare-app

ARG URL=https://github.com/invoiceninja/invoiceninja/releases/latest/download/invoiceninja.tar.gz

ADD ${URL} /tmp/invoiceninja.tar.gz

RUN tar -xf /tmp/invoiceninja.tar.gz \
    && ln -s ./resources/views/react/index.blade.php ./public/index.html \
    # Symlink
    && php artisan storage:link \
    # Octane
    && php artisan octane:install --server=frankenphp

# ==================
# InvoiceNinja image
# ==================
FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION}-${DEBIAN_VERSION} AS base

ARG user=ninja

# PHP modules
ARG php_require="bcmath gd mbstring pdo_mysql zip"
ARG php_suggest="exif imagick intl pcntl saxon soap"
ARG php_extra="opcache"
ARG saxon_edition="HE"

# Create a system user UID/GID=999
RUN	useradd -r ${user}

# Allow to bind to privileged ports
RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    mariadb-client \
    # Unicode support for PDF
    fonts-noto-cjk-extra \
    fonts-wqy-microhei \
    fonts-wqy-zenhei \
    xfonts-wqy \
    # Create config directory for chromium
    && mkdir /config/chromium \
    && chown ${user}: /config/chromium \
    # Cleanup
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN ( curl -sSLf https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -o - || echo 'return 1' ) | IPE_SAXON_EDITION=${saxon_edition} sh -s \
    ${php_require} \
    ${php_suggest} \
    ${php_extra}

# Configure PHP
RUN ln -s "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"

COPY ./php.ini /usr/local/etc/php/conf.d/invoiceninja.ini

# Create directory for artisan tinker (init.sh)
RUN mkdir /config/psysh \
    && chown ${user}: /config/psysh

# Change owner for caddy directories
RUN chown -R ${user}: \
    /data/caddy \
    /config/caddy

# InvoiceNinja
COPY --from=prepare-app --chown=${user}:${user} /app /app

# Add initialization script
COPY --chmod=0755 ./entrypoint.sh /usr/local/bin/entrypoint.sh

USER ${user}

ENV FILESYSTEM_DISK=debian_docker
ENV IS_DOCKER=true
ENV SNAPPDF_CHROMIUM_PATH=/usr/bin/chromium

ENTRYPOINT ["entrypoint.sh"]

FROM base AS app
ENV LARAVEL_ROLE=app
HEALTHCHECK --start-period=100s CMD curl -f http://localhost/health
CMD ["frankenphp", "php-cli", "artisan", "octane:frankenphp"]

FROM base AS scheduler
ENV LARAVEL_ROLE=scheduler
HEALTHCHECK --start-period=10s CMD pgrep -f schedule:work
CMD ["frankenphp", "php-cli", "artisan", "schedule:work"]

FROM base AS worker
ENV LARAVEL_ROLE=worker
HEALTHCHECK --start-period=10s CMD pgrep -f queue:work
CMD ["frankenphp", "php-cli", "artisan", "queue:work"]
