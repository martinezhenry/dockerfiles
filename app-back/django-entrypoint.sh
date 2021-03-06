#!/bin/bash
set -e

APPDIR=${APP_PATH}

ls -la /app/

cd $APPDIR

echo $APPDIR

if [ "$1" = 'gunicorn' ] || [ "${#}" -eq 0 ]; then
        echo -n "[INFO] Running 'python manage.py collectstatic'..."
        python manage.py collectstatic --noinput >/dev/null
        echo "[OK]"
        echo "[INFO] Running 'python manage.py migrate'..."
        python manage.py migrate --noinput
        ## start uWSGI
        uwsgi --master --http 0.0.0.0:8000 --chdir /app/ --wsgi-file /app/app-back/wsgi.py \
        --static-map /static/=/app/static/ --static-map /media/=/app/media/       \
        --uid django --gid django --processes 5 --buffer-size=32768
else
        exec "$@"
fi

