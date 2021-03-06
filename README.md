# Backend for findcovidtesting.com

## Endpoints

### Base URL
`api.findcovidtesting.com`

### List locations
GET `/api/v1/location`

Optionally search to an area with source_latitude, source_longitude, distance

Example:

```
curl -s -X GET 'localhost:5000/api/v1/location?source_latitude=30.267153&source_longitude=-97.743057&distance=5'
```

### Get location
GET `/api/v1/location{location_id}`

### Get Latest Location Timestamp
Returns the timestamp of the most recently updated verified location

GET `/api/v1/recentLocation`

### Create location
Requires basic auth

POST `/api/v1/location`

### Upload CSV file
Requires basic auth

This will upload a csv which will get asynchronously converted to json and uploaded to db

POST `/api/v1/location/csv`

### Update location
Requires basic auth

PUT `/api/v1/location{location_id}?field=field_name&value=field_value`

`field` - a field name in the schema
`value` - url encoded value, assumes application/x-www-form-urlencoded type data

## Features

* Flask + blueprints
* SQLAlchemy
* AWS Parameter Support for grabbing env and secrets
* Docker
* Nginx + uWSGI
* Lots of automation

## Development

Start PG, pgadmin, and flask in docker:

```
make up
```

Create the schema:

```
make db_create
```

Create and apply migrations:

```
make migrate
```

Stop docker environment:

```
make stop
```

PG and pgadmin use volumes so their data is preserved.

## Deploying

Build and push to ECR
```
make push
```

```
make ENVIRONMENT=production push
```

## Database Tasks
The DB schema needs to get created in RDS before using an environment 

```
make ENVIRONMENT=xyz create_db_fargate
```

### Environments
* Staging
* Production

### Secrets
All secrets are stored in AWS Parameter Store with KMS encryption. The naming structure is:

`$ENVIRONMENT/backend/$VAR_IN_CAPS`

### Adding dependencies
```shell
scripts/pip_install.sh XYZ
```

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
