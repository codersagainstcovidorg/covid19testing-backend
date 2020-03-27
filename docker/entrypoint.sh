#!/bin/bash

export FLASK_APP="application"

# placeholder for start up tasks

if [[ "$1" == "start" ]]; then
  exec /usr/bin/supervisord
fi

exec "$@"