#!/usr/bin/env bash

# Ensure database is ready to accept a connection
echo "About to try db..."
while ! nc -z db 5432; do
  echo "BD not ready, will try again shortly"
  sleep 1
done
echo "Connected to DB, will continue processing"
sleep 5

if ! grep -q '^SECRET_KEY=' tardis/settings.py; then
python -c "import os; from random import choice; key_line = '%sSECRET_KEY=\"%s\"  # generated from build.sh\n' % ('from tardis.settings_changeme import * \n\n' if not os.path.isfile('tardis/settings.py') else '', ''.join([choice('abcdefghijklmnopqrstuvwxyz0123456789\\!@#$%^&*(-_=+)') for i in range(50)])); f=open('tardis/settings.py', 'a+'); f.write(key_line); f.close()"
fi

enable_bioformats="${MYTARDIS_ENABLE_FILTER_BIOFORMATS}"
[[ "${MYTARDIS_ENABLE_FILTER_BIOFORMATS}" == 'True' ]] && export MYTARDIS_ENABLE_FILTER_BIOFORMATS='False'

echo 'python manage.py createcachetable default_cache'
python manage.py createcachetable default_cache
echo 'python manage.py createcachetable celery_lock_cache'
python manage.py createcachetable celery_lock_cache
echo 'python manage.py collectstatic --noinput'
python manage.py collectstatic --noinput	# Collect static files

echo 'python manage.py migrate'
python manage.py migrate	# Apply database migrations

# Bioformats filter
# https://github.com/keithschulze/mytardisbf
export MYTARDIS_ENABLE_FILTER_BIOFORMATS="${enable_bioformats}"
if [[ "${MYTARDIS_ENABLE_FILTER_BIOFORMATS}" == 'True' ]]; then
  echo 'python manage.py loaddata src/mytardisbf/mytardisbf/fixtures'
  python manage.py loaddata src/mytardisbf/mytardisbf/fixtures
fi

# https://github.com/mytardis/mytardis-app-mydata\
echo 'python mytardis.py loaddata tardis/apps/mydata/fixtures/default_experiment_schema.json'
python mytardis.py loaddata tardis/apps/mydata/fixtures/default_experiment_schema.json

# Prepare log files and start outputting logs to stdout
touch /srv/logs/gunicorn.log
touch /srv/logs/access.log
tail -n 0 -f /srv/logs/*.log &

# Start Gunicorn processes
echo Starting Gunicorn.
exec gunicorn wsgi:application \
  --name django \
  --bind 0.0.0.0:8000 \
  --workers 3 \
  --log-level=info \
  --log-file=/srv/logs/gunicorn.log \
  --access-logfile=/srv/logs/access.log \
  "$@"
