APP_NAME := covid19testing-backend
SHELL := /bin/bash

.PHONY: all

all: start

dev_setup:
	python3 -m venv venv
	. venv/bin/activate
	pip install -r requirements.txt

dev_build:
	docker build -t $(APP_NAME):latest -f Dockerfile.dev .

start: dev_build
	
	docker run -it -v $(PWD):/app $(APP_NAME):latest