# Backend for findcovidtesting.com

## Help Appreciated For These Items

* Unit tests + test automation

## Features

* Flask + blueprints
* SQLAlchemy
* Native AWS Parameter Support for grabbing env and secrets
* Docker
* Lots of automation

## Development

Set up virtualenv:

```shell
make dev_setup
```

Start database and pgadmin:

```
make up
```

Start flask

```shell
make start
```

Stop database and pgadmin:

```
make stop
```


### Environments
* Dev - local dev
* Staging
* Production

### Secrets
All secrets are stored in AWS Parameter Store with KMS encryption. The naming structure is:

`$ENVIRONMENT/backend/$VAR_IN_CAPS`

### Adding dependencies
```shell
pip install XYZ
pip freeze > requirements.txt
```

or you can do `scripts/pip_install.sh XYZ` and save a few seconds of typing

## Structure
```text
├── application - the app code
├── config.py - Parameterized app config
├── create_db.py - Run this to create the DB schema
├── docker - Directory of docker specific scripts for use in dockerfile
├── docker-compose.py - Runs PG, PG admin, and the app
├── docker-compose.yml - local development
├── Dockerfile
├── scripts - Directory of automation scripts for use outside of dockerfile
└── wsgi.py - Hook for launching the app instance
```