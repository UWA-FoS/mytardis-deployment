#!/usr/bin/env bash

python manage.py migrate	# Apply database migrations
python manage.py collectstatic --noinput	# Collect static files
python manage.py createcachetable default_cache
python manage.py createcachetable celery_lock_cache

# Prepare log files and start outputting logs to stdout
touch /srv/logs/gunicorn.log
touch /srv/logs/access.log
tail -n 0 -f /srv/logs/*.log &

if ! grep -q '^SECRET_KEY=' tardis/settings.py; then
python -c "import os; from random import choice; key_line = '%sSECRET_KEY=\"%s\"  # generated from build.sh\n' % ('from tardis.settings_changeme import * \n\n' if not os.path.isfile('tardis/settings.py') else '', ''.join([choice('abcdefghijklmnopqrstuvwxyz0123456789\\!@#$%^&*(-_=+)') for i in range(50)])); f=open('tardis/settings.py', 'a+'); f.write(key_line); f.close()"
fi

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
