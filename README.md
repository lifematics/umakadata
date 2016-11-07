# Umakadata

Ruby on Rails application for Umakadata.

This repository contains RoR application and Dockerfile that makes setup easy.

## Prerequisites

Getting started with docker, Umakadata requires these packages installed.

- OS X or Windows

    - Docker (1.11.0 confirmed)
    - Docker-machine (0.7.0 confirmed)
    - Docker-compose (1.7.0 confirmed)

- Linux

    - Docker-engine (1.7.1 comfirmed)

If you already get another version of Docker running, it may be used as alternative environment. 

## Installation

### OS X or Windows

#### 1. Run containers

Docker-compose will help you with building images and running containers.
```bash
cd /path/to/umakadata
docker-compose up -d
```

#### 2. Initialize

```bash
# Enter to web container's shell
docker-compose exec web /bin/bash
# Now you are in the container
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake umakadata:active_median
```

### Linux

#### 1. Pull and build images

Pull the PostgreSQL image from official repository.
```bash
docker pull postgres
```

Build Ruby and RoR environment.
```bash
cd /path/to/umakadata
docker build --tag umakadata_web .
```

#### 2. Run containers

##### Container for database

```bash
# Make directory to mount into container
mkdir pgdata
docker run -d -v /path/to/pgdata:/var/lib/postgresql/data -p 5432:5432 --name umakadata_db postgres
```

If you want to use a role other than postgres, use the command below instead.
```bash
docker run -d -v /path/to/pgdata:/var/lib/postgresql/data -p 5432:5432 --name umakadata_db \
           -e "POSTGRES_USER=user" -e "POSTGTES_PASS=password" postgres
```

Note: You will need to update user name and password in `umakadata/web/config/database.yml`.

##### Container for web application

```bash
docker run -d -p 3000:3000 --name umakadata_web umakadata_web bundle exec rails s -p 3000 -b '0.0.0.0'
```

#### 3. Initialize

```bash
docker exec -it umakadata_web /bin/bash
# Now you are in the container
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake umakadata:active_median
```

## Usage


## Development


## Contributing


## License

