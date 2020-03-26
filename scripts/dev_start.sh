#!/bin/bash
export FLASK_APP="application"
export FLASK_ENV=development
export SQLALCHEMY_DATABASE_URI="postgres://covid:covid@localhost:5432/covid"
export BASIC_AUTH_USERNAME=covid
export BASIC_AUTH_PASSWORD=covid
flask run