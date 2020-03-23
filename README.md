# Covid19testing-backend

# WIP
excuse the brevity

# Local Development

Set up virtualenv:

```shell
make dev_setup
```

Start flask

```shell
make start
```

## Structure
```text
├── Dockerfile - Main app
├── Dockerfile.base - Base "OS" components, required packages
├── docker - Directory of docker specific scripts for use in dockerfile
├── docker-compose.yml - local development
└── scripts - Directory of automation scripts for use outside of dockerfile
```