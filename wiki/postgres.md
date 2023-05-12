Because the postgres CLI is the epitome of obviousness

## List schemas

    \dn

### Set schema

    SET SEARCH_PATH = some_db_schema;

## List tables

    \dt
    \dt schema_name.*
    \dt *.*

## Describe table

    \d schema_name.table_name

## List permissions (per DB)

Per table

    \z schema_name.table_name

For entire database

    \l

## Add permissions

    GRANT CONNECT ON DATABASE database_name TO username;
    GRANT USAGE ON SCHEMA schema_name TO username;
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA schema_name TO username;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA schema_name TO username;
