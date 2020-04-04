#!/bin/bash

export FLASK_APP="application"

if [[ "$1" == "start" ]]; then
  docker/migrate.sh
  exec /usr/bin/supervisord
fi

if [[ "$1" == "create" ]]; then
  exec python create_db.py
fi

exec "$@"