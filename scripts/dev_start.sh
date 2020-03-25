#!/bin/bash
export FLASK_APP="application"
export SQLALCHEMY_DATABASE_URI="postgres://covid:covid@localhost:5432/covid"
flask run