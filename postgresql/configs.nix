
{ pkgs }:

let

  postgres-base-conf = ''
    ## For Global PostgreSQL behaviors
    listen_addresses = '*'
    max_connections = 500
    shared_preload_libraries = 'pg_stat_statements,powa,pg_stat_kcache,pg_qualstats'

    #ssl = on
    #ssl_cert_file = '/etc/postgresql/server.crt'
    #ssl_key_file  = '/etc/postgresql/server.key'

    log_line_prefix = '%t [%p-%l] %q%u@%d '
    log_timezone = 'Europe/Zurich'
    timezone = 'UTC'
    lc_messages = 'en_US.UTF-8'
    lc_monetary = 'en_US.UTF-8'
    lc_numeric = 'en_US.UTF-8'
    lc_time = 'en_US.UTF-8'
    default_text_search_config = 'pg_catalog.english'

    logging_collector=on

    ## For POWA (default)
    track_io_timing = on
    powa.frequency = 5min
    powa.retention = 1d
    powa.database = powa
    powa.coalesce = 100
    log_min_duration_statement = 850

    ## For pg_stat_statements extension
    pg_stat_statements.max = 1000
    pg_stat_statements.track = all
  '';

in {
  postgres-conf = postgres-base-conf;

  powa-web-config =  pkgs.writeText "powa-web.conf" ''
    servers={
      'main': {
        'host': 'localhost',
        'port': '5432',
        'database': 'powa'
      }
    }
    cookie_secret="SUPERSECRET_THAT_YOU_SHOULD_CHANGE"
  '';

  pg_hba = ''
    local   all           all                        trust
    host    all           all      127.0.0.1/32      trust
    host    all           all      ::1/128           trust
    host    all           all      192.168.0.0/16    md5
  '';

  postgresInitScript = pkgs.writeText "pg-init" ''
    /*
     * secure root
     */
    ALTER USER root PASSWORD 'woo4inoolohT';

    /*
     * create postgres superuser
     */
    CREATE USER postgres WITH
      LOGIN
      SUPERUSER
      INHERIT
      CREATEDB
      CREATEROLE
      REPLICATION
      PASSWORD 'postgres1234';
    GRANT ALL PRIVILEGES ON DATABASE postgres to postgres;
    \connect postgres postgres

    CREATE EXTENSION pg_stat_statements ;

    /*
     * postgres_exporter
     */
    CREATE USER postgres_exporter WITH
      LOGIN
      NOSUPERUSER
      INHERIT
      NOCREATEDB
      NOCREATEROLE
      NOREPLICATION
      PASSWORD 'Aechoh7yoogi';
    ALTER USER postgres_exporter SET SEARCH_PATH TO postgres_exporter,pg_catalog;

    CREATE SCHEMA postgres_exporter AUTHORIZATION postgres_exporter;

    CREATE FUNCTION postgres_exporter.f_select_pg_stat_activity()
    RETURNS setof pg_catalog.pg_stat_activity
    LANGUAGE sql
    SECURITY DEFINER
    AS $$
      SELECT * from pg_catalog.pg_stat_activity;
    $$;

    CREATE FUNCTION postgres_exporter.f_select_pg_stat_replication()
    RETURNS setof pg_catalog.pg_stat_replication
    LANGUAGE sql
    SECURITY DEFINER
    AS $$
      SELECT * from pg_catalog.pg_stat_replication;
    $$;

    CREATE VIEW postgres_exporter.pg_stat_replication
    AS
      SELECT * FROM postgres_exporter.f_select_pg_stat_replication();

    CREATE VIEW postgres_exporter.pg_stat_activity
    AS
      SELECT * FROM postgres_exporter.f_select_pg_stat_activity();

    GRANT SELECT ON postgres_exporter.pg_stat_replication TO postgres_exporter;
    GRANT SELECT ON postgres_exporter.pg_stat_activity TO postgres_exporter;

    /*
     * POWA
     */
    CREATE DATABASE powa WITH
      OWNER = postgres
      ENCODING = 'UTF8'
      LC_COLLATE = 'en_US.UTF-8'
      LC_CTYPE = 'en_US.UTF-8'
      TABLESPACE = pg_default
      CONNECTION LIMIT = -1;
    ALTER DATABASE powa OWNER TO postgres;
    CREATE USER powa WITH
      LOGIN
      NOSUPERUSER
      INHERIT
      NOCREATEDB
      NOCREATEROLE
      NOREPLICATION
      PASSWORD 'powa';
    \connect powa;

    CREATE EXTENSION pg_stat_statements ;
    CREATE EXTENSION btree_gist ;
    CREATE EXTENSION powa;

    GRANT SELECT ON ALL TABLES IN SCHEMA public TO powa;
    GRANT SELECT ON pg_statistic TO powa;
  '';



}
