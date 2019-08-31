# Docker img for Pentaho server with external repository

This image is based on `ubuntu` and delivers a Pentaho Server that connects to a repository specified on environment variables.

> **NOTE**: It's currently configured to use PostgreSQL but its idea is to be more generic.

There's a `docker-compose.yml` included that makes it easier to run. To get going, you should have a running database (PostgreSQL) instance.

## Building

```bash
docker-compose build
```

## Usage

This Pentaho image assumes you have a Repository running somewhere. You'll then need to inform the Repository connection properties via environment variables passed down to the container.

If you're in development, see [Postgres container for development](#Postgres-container-for-development) for starting a local database instance. Remember that containers are stateless.

If you want to create a fresh repository in a running PostgreSQL instance, see [Prepare a running instance](#prepare-a-running-instance).

### Starting Pentaho Server

This will start a Pentaho Server that will try to connect to the specified PostgreSQL instance as its 

```bash
PGSQL_HOST=DB_HOST \
  PGSQL_PORT=5432 \
  PGSQL_USER=postgres \
  PGSQL_PASSWORD=dummymummy && \
  docker-compose up -d pentaho-server
```

### Postgres container for development

The following command will initialize a postgres running at port `5432` with user `postgres` and password
 `dummymummy`.

```sh
PGSQL_PASSWORD=dummymummy \
  docker-compose up -d pgsql_pentaho 
```
### Prepare a running instance

The following command will execute creation scripts on the postgres instance you indicate. To run a simple postgres container, see [Testing with a local postgres](#testing-with-a-local-postgres)

```bash
PGSQL_HOST=DB_HOST \
  PGSQL_PORT=5432 \
  PGSQL_USER=postgres \
  PGSQL_PASSWORD=dummymummy && \
  docker-compose run pentaho-server initdb
```
