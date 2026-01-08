#!/bin/bash -eu

# --- ROLE: aio (Runs as root) ---
if [ "${LARAVEL_ROLE}" = 'aio' ]; then
    # Clear and cache config in production
    if [ "$*" = 'supervisord -c /etc/supervisor/supervisord.conf' ]; then
        if [ "$APP_ENV" = "production" ]; then
            echo "Running production setup..."
            runuser -u ninja -- php artisan migrate --force
            runuser -u ninja -- php artisan cache:clear
            runuser -u ninja -- php artisan ninja:design-update
            runuser -u ninja -- php artisan optimize

            # Check if initialization is needed
            if [ "$(runuser -u ninja -- php artisan tinker --execute='echo Schema::hasTable("accounts") && !App\Models\Account::all()->first();')" = "1" ]; then
                echo "Running initialization..."
                runuser -u ninja -- php artisan db:seed --force
                if [ -n "${IN_USER_EMAIL}" ] && [ -n "${IN_PASSWORD}" ]; then
                    runuser -u ninja -- php artisan ninja:create-account --email "${IN_USER_EMAIL}" --password "${IN_PASSWORD}"
                else
                    echo "Initialization failed - Set IN_USER_EMAIL and IN_PASSWORD in .env"
                    exit 1
                fi
            fi
        fi
    fi
    echo "Handing off to supervisord..."
    # Fall through to exec "$@" at the bottom

# --- ROLES: app, worker, scheduler (Run as ninja) ---
else
    if [ "--help" = "$1" ]; then
        echo [FLAGS]
        echo The CMD defined can be extended with flags for artisan commands
        echo
        echo Available flags can be displaced:
        echo docker run --rm benbrummer/invoiceninja:5-app php artisan help octane:frankenphp
        echo docker run --rm benbrummer/invoiceninja:5-worker php artisan help queue:work
        echo docker run --rm benbrummer/invoiceninja:5-scheduler php artisan help schedule:work
        echo
        echo Example:
        echo docker run benbrummer/invoiceninja:5-worker --verbose --sleep=3 --tries=3 --max-time=3600
        echo
        echo [Deployment]
        echo Docker compose is recommended
        echo
        echo Example:
        echo https://github.com/benbrummer/dockerfiles/blob/main/sample.compose.yaml
        echo
        exit 0
    fi

    case "${LARAVEL_ROLE}" in
    app)
        # Check if we should prepend the octane command
        if [ $# -eq 0 ] || [[ "$1" == -* ]] || [ "$*" = "php artisan octane:frankenphp" ]; then
            if [ "$APP_ENV" = "production" ]; then
                echo "Running production setup..."
                php artisan migrate --force
                php artisan cache:clear
                php artisan ninja:design-update
                php artisan optimize

                if [ "$(php artisan tinker --execute='echo Schema::hasTable("accounts") && !App\Models\Account::all()->first();')" = "1" ]; then
                    echo "Running initialization..."
                    php artisan db:seed --force
                    if [ -n "${IN_USER_EMAIL:-}" ] && [ -n "${IN_PASSWORD:-}" ]; then
                        php artisan ninja:create-account --email "${IN_USER_EMAIL}" --password "${IN_PASSWORD}"
                    fi
                fi
            fi

            # CRITICAL FIX: Prepend the base command if only flags were passed
            if [ $# -eq 0 ] || [[ "$1" == -* ]]; then
                set -- php artisan octane:frankenphp "$@"
            fi
        fi
        ;;

    scheduler)
        [ "$APP_ENV" = "production" ] && php artisan optimize
        echo "Starting Scheduler loop..."

        # Catch signals to exit the loop immediately
        trap "echo 'Stopping scheduler...'; exit 0" SIGTERM SIGINT

        while true; do
            touch /tmp/scheduler_heartbeat
            # Run scheduler in background, output still goes to stdout
            php artisan schedule:run --no-interaction "$@" &
            wait $! # Wait for the command to finish

            # Sleep in background so the 'trap' can interrupt it
            sleep 60 &
            wait $!
        done
        ;;

    worker)
        [ "$APP_ENV" = "production" ] && php artisan optimize
        echo "Starting Worker..."
        if [ $# -eq 0 ] || [[ "$1" == -* ]]; then
            set -- php artisan queue:work --no-interaction "$@"
        fi
        ;;
    esac

fi

exec "$@"
