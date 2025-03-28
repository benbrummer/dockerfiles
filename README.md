[![Docker Image Size](https://img.shields.io/docker/image-size/benbrummer/invoiceninja)](https://hub.docker.com/r/benbrummer/invoiceninja)
[![Docker Pulls](https://img.shields.io/docker/pulls/benbrummer/invoiceninja)](https://hub.docker.com/r/benbrummer/invoiceninja)
[![Build Status](https://github.com/benbrummer/dockerfiles/actions/workflows/bake.yaml/badge.svg)](https://github.com/benbrummer/dockerfiles/actions/workflows/bake.yaml)

# FrankenPHP based Image for [Invoice Ninja](https://www.invoiceninja.com/)

> :information_source: Image will be deployed with each release of [Invoice Ninja](https://github.com/invoiceninja/invoiceninja/releases) to https://hub.docker.com/r/benbrummer/invoiceninja for `arm64` and `amd64`


:crown: **Features**

aligned with [invoiceninja-debian](https://github.com/invoiceninja/dockerfiles/tree/debian)

extended with

* [FrankenPHP](https://frankenphp.dev/)
* [Octane](https://laravel.com/docs/master/octane)
* [Chromium for PDF generation](https://www.chromium.org)
* [MariaDB](https://mariadb.org/)
* [Valkey](https://valkey.io/)

## Get started

```bash
git clone https://github.com/benbrummer/dockerfiles.git
cd dockerfiles
```

1. Make a copy of `sample.compose.yaml` named `compose.yaml` and adapt it to your needs. A simple help menu for the image(s) can be displayed by running `docker run --rm benbrummer/invoiceninja:5-octane --help`
1. Instead of defining environment variables inside the compose.yaml file, these need to be set in a `.env` file. Create a copy of `sample.env` file named `.env`.
1. Open this file and insert your `APP_URL`, `APP_KEY` and update the rest of the variables as required.

## Generate a APP_KEY

The `APP_KEY` can be generated by running:

```bash
# If you haven't started the containers yet:
docker run --rm -it benbrummer/invoiceninja:5-octane frankenphp php-cli artisan key:generate --show

# Or if your containers are already running:
docker compose exec app frankenphp php-cli artisan key:generate --show
```

Copy the entire string and insert in the `.env` file at `APP_KEY=base64....`

## Initial account setup

Prior to starting the container for the first time, open the .env file and update the IN_USER_EMAIL and IN_PASSWORD variables with your primary account. 

This will take care of the initial account setup. You can later remove these .env variables.

> :warning: **Warning**  
> If `IN_USER_EMAIL` and `IN_PASSWORD` are not set the default user email and password is "admin@example.com" and "changeme!" respectively. 

After the container has completed the first startup, you can delete these two environment variables.

Start the container with:

```bash
docker compose up -d
```

**Note: When performing the setup, the Database host is `mariadb`

## Updating the Image

To upgrade to a newer release image, update your compose.yaml first by running:

```bash
docker compose pull
docker compose up -d
```

It is recommended to perform a backup before updating.

## Support

If you discover a bug related to this image, please create an [issue](https://github.com/benbrummer/dockerfiles/issues) in this repository.

Support for Invoice Ninja itself can be requested trough the official ressources

* [Forum](https://forum.invoiceninja.com/)
* [Invoice Ninja](https://github.com/invoiceninja/invoiceninja)
* [Official Dockerfiles](https://github.com/invoiceninja/dockerfiles)

## Customizing PHP Settings

`./php/php.ini` is baked into the image as `/usr/local/etc/php/conf.d/invoiceninja.ini`. Adapting php values to your needs is done by mounting additional `ini-files` into `/usr/local/etc/php/conf.d/`. The files are considered in alphabetical order. The last value will be taken.

```yaml
x-app-volumes: &volumes
  volumes:
      # Modified php.ini overwrites the invoiceninja.ini baked into the image
      - ./php/php.ini:/usr/local/etc/php/conf.d/invoiceninja.ini
```

## Building the Image

> :information_source: To build just for a specific platform use `--set *.platform=linux/amd64` with the `bake` command

### Latest

```bash
docker buildx bake -f docker-bake.hcl
```

### Building a specific version based on `version.txt`

```bash
source version.sh
docker buildx bake -f docker-bake.hcl
```
