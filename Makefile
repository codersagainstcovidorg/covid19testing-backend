APP_NAME := covid19testing-backend
SHELL := /bin/bash

.PHONY: all

all: base build

dev_setup:
	scripts/dev_setup.sh

base:
	docker build -t $(APP_NAME)-base:latest -f Dockerfile.base .

build:
	docker build -t $(APP_NAME):latest .

start: 
	scripts/start.sh