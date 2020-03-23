# Backend for findcovidtesting.com

## Help Appreciated For These Items

* Unit tests + test automation

## Features

* Flask + blueprints
* SQLAlchemy
* Native AWS Parameter Support for grabbing env and secrets
* Docker
* Automation!


## Development

Set up virtualenv:

```shell
make dev_setup
```

Start flask

```shell
make start
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
├── Dockerfile - Main app
├── Dockerfile.base - Base "OS" components, required packages
├── docker - Directory of docker specific scripts for use in dockerfile
├── docker-compose.yml - local development
└── scripts - Directory of automation scripts for use outside of dockerfile
```