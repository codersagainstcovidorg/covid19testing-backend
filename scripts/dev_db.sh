#!/bin/bash
# Create DB schema locally
export FLASK_APP="application"
export SQLALCHEMY_DATABASE_URI="postgres://covid:covid@localhost:5432/covid"
python create_db.py