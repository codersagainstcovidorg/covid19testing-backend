#!/bin/bash

export FLASK_APP="application"

# placeholder for start up tasks

if [[ "$1" == "start" ]]; then
  exec /usr/bin/supervisord
fi

if [[ "$1" == "create" ]]; then
  exec python create_db.py
fi

exec "$@"