APP_NAME := covid19testing-backend
SHELL := /bin/bash

.PHONY: all

all: base build

dev_setup:
	scripts/dev_setup.sh

db_create:
	scripts/create_db.sh

docker_build:
	docker build -t $(APP_NAME):latest .

start: 
	scripts/dev_start.sh

up:
	docker-compose up -d

stop:
	docker-compose stop