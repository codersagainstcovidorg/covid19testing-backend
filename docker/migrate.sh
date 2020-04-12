#!/bin/bash

echo "starting migrations"
flask db migrate
flask db upgrade
echo "finished"