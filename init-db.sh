#!/bin/bash
set -e

# Create the nathan_for_us database if it doesn't exist
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT 'CREATE DATABASE nathan_for_us_prod'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'nathan_for_us_prod')\gexec
EOSQL
