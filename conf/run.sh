#!/bin/bash

cd /app/askbot_app

export PYTHONPATH=/app/askbot_app:$PYTHONPATH

if [ ! -d /data/contrib ]; then
  mkdir /data/contrib;
fi

if [ ! -d /data/logs ]; then
  mkdir /data/logs;
fi

if [ ! -d /data/nginx ]; then
  mkdir /data/nginx;
  mkdir /data/nginx/certs;
  mkdir /data/nginx/html;
  mkdir /data/vhost.d;
fi

if [ ! -d /data/override ]; then
  mkdir /data/override;
  touch /data/override/settingsoverride.py;
fi

ls -laR /app

cd /app

python3 manage.py collectstatic --noinput
# python3 manage.py syncdb --noinput
python3 manage.py makemigrations --noinput
python3 manage.py migrate --noinput

# Run via debugging server
exec /usr/local/bin/uwsgi /app/askbot_app/uwsgi.ini
