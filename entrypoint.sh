#!/bin/sh -eu

if [ "--help" = "$1" ]; then
    echo [FLAGS]
    echo The CMD defined can be extended with flags for artisan commands
    echo
    echo Available flags can be displaced:
    echo docker run --rm benbrummer/invoiceninja:5-octane frankenphp php-cli artisan help octane:frankenphp
    echo docker run --rm benbrummer/invoiceninja:5-octane-worker frankenphp php-cli artisan help queue:work
    echo docker run --rm benbrummer/invoiceninja:5-octane-scheduler frankenphp php-cli artisan help schedule:work
    echo
    echo Example:
    echo docker run benbrummer/invoiceninja:5-octane-worker --verbose --sleep=3 --tries=3 --max-time=3600
    echo
    echo [Deployment]
    echo Docker compose is recommended
    echo
    echo Example:
    echo https://github.com/benbrummer/dockerfiles/blob/octane-action/sample.compose.yaml
    echo
    exit 0
fi

case "${LARAVEL_ROLE}" in
app)
    if [ "$*" = 'frankenphp php-cli artisan octane:frankenphp' ] || [ "${1#-}" != "$1" ]; then
        cmd="frankenphp php-cli artisan octane:frankenphp"

        if [ "$APP_ENV" = "production" ]; then
            frankenphp php-cli artisan migrate --force
            frankenphp php-cli artisan cache:clear # Clear after the migration
            frankenphp php-cli artisan ninja:design-update
            frankenphp php-cli artisan optimize

            # If first IN run, it needs to be initialized
            if [ "$(frankenphp php-cli artisan tinker --execute='echo Schema::hasTable("accounts") && !App\Models\Account::all()->first();')" = "1" ]; then
                echo "Running initialization..."

                frankenphp php-cli artisan db:seed --force

                if [ -n "${IN_USER_EMAIL}" ] && [ -n "${IN_PASSWORD}" ]; then
                    frankenphp php-cli artisan ninja:create-account --email "${IN_USER_EMAIL}" --password "${IN_PASSWORD}"
                else
                    echo "Initialization failed - Set IN_USER_EMAIL and IN_PASSWORD in .env"
                    exit 1
                fi
            fi
        fi
    fi
    ;;

scheduler)    
    if [ "$*" = 'frankenphp php-cli artisan schedule:work' ] || [ "${1#-}" != "$1" ]; then
        cmd="frankenphp php-cli artisan schedule:work"
    fi

    if [ "$APP_ENV" = "production" ]; then
        frankenphp php-cli artisan optimize
    fi
    ;;

worker)
    if [ "$*" = 'frankenphp php-cli artisan queue:work' ] || [ "${1#-}" != "$1" ]; then
        cmd="frankenphp php-cli artisan queue:work"
    fi

    if [ "$APP_ENV" = "production" ]; then
        frankenphp php-cli artisan optimize
    fi
    ;;

esac

# Append flag(s) to role cmd
if [ "${1#-}" != "$1" ] && [ -n "$cmd" ]; then
    set -- ${cmd} "$@"
fi

exec "$@"
