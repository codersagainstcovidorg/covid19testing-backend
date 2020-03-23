APP_NAME := covid19testing-backend
SHELL := /bin/bash

.PHONY: all

all: base build

dev_setup:
	python3 -m venv venv
	. venv/bin/activate
	pip install -r requirements.txt

base:
	docker build -t $(APP_NAME)-base:latest -f Dockerfile.base .

build:
	docker build -t $(APP_NAME):latest .

start: 
	scripts/start.sh