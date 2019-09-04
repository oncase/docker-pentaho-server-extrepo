#!/bin/bash
cd data/postgresql
sed -i '/^drop user/d' create_quartz_postgresql.sql
sed -i '/^CREATE USER/d' create_quartz_postgresql.sql
sed -i 's/CREATE DATABASE quartz.*$/ CREATE DATABASE quartz ENCODING = \x27UTF8\x27;/g' create_quartz_postgresql.sql
sed -i '/^GRANT ALL/d' create_quartz_postgresql.sql
sed -i '/ OWNER TO /d' create_quartz_postgresql.sql
sed -i 's/connect quartz pentaho_user/connect quartz/g' create_quartz_postgresql.sql

sed -i '/^drop user/d' create_jcr_postgresql.sql
sed -i '/^CREATE USER/d' create_jcr_postgresql.sql
sed -i '/^GRANT ALL/d' create_jcr_postgresql.sql
sed -i 's/CREATE DATABASE jackrabbit.*$/ CREATE DATABASE jackrabbit ENCODING = \x27UTF8\x27 ;/g' create_jcr_postgresql.sql
sed -i '/^drop user/d' create_repository_postgresql.sql
sed -i '/^CREATE USER/d' create_repository_postgresql.sql
sed -i '/^GRANT ALL/d' create_repository_postgresql.sql
sed -i 's/CREATE DATABASE hibernate.*$/ CREATE DATABASE hibernate ENCODING = \x27UTF8\x27 ;/g' create_repository_postgresql.sql


PGPASSWORD=${PGSQL_PASSWORD} \
  psql -U ${PGSQL_USER} -p ${PGSQL_PORT} -h ${PGSQL_HOST} -f create_jcr_postgresql.sql;
PGPASSWORD=${PGSQL_PASSWORD} \
  psql -U ${PGSQL_USER} -p ${PGSQL_PORT} -h ${PGSQL_HOST} -f create_quartz_postgresql.sql;
PGPASSWORD=${PGSQL_PASSWORD} \
  psql -U ${PGSQL_USER} -p ${PGSQL_PORT} -h ${PGSQL_HOST} -f create_repository_postgresql.sql;
