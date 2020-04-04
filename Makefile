APP_NAME := covid-backend
ENVIRONMENT ?= staging
TAG ?= latest
SHELL := /bin/bash

REGION ?= us-east-1
ACCOUNT_ID := 656509764755
ECR_URL := $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(ENVIRONMENT)-$(APP_NAME)

.PHONY: all

all: base build

dev_setup:
	scripts/dev_setup.sh

db_create:
	scripts/dev_db.sh

docker_build:
	docker build -t $(APP_NAME):$(TAG) .

start: 
	scripts/dev_start.sh

up:
	docker-compose up -d

stop:
	docker-compose stop

push: docker_build
	@aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ECR_URL)
	docker tag $(APP_NAME):$(TAG) $(ECR_URL):$(TAG)
	docker push $(ECR_URL):$(TAG)

create_db_fargate: push
	scripts/create_db_fargate.sh $(ENVIRONMENT)

migrate:
	SQLALCHEMY_DATABASE_URI=postgres://covid:covid@localhost:5432/covid  flask db migrate
	SQLALCHEMY_DATABASE_URI=postgres://covid:covid@localhost:5432/covid  flask db upgrade