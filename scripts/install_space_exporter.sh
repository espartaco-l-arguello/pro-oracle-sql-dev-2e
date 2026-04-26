#!/usr/bin/env bash
set -e
echo "Installing SPACE_EXPORTER and fixing dependencies..."
mkdir -p /tmp/sdb_extracted
tar -xzf space-master/raw_data/sdb.tar.gz -C /tmp/sdb_extracted
docker cp /tmp/sdb_extracted/sdb/. oracledb:/opt/oracle/oradata/
docker exec -i oracledb bash -c "mv /opt/oracle/oradata/-all /opt/oracle/oradata/all 2>/dev/null || true"
docker cp /tmp/sdb_extracted/lvtemplate oracledb:/opt/oracle/oradata/ 2>/dev/null || true
mkdir -p /tmp/satcat_extracted
unzip -q space-master/raw_data/satcat.zip -d /tmp/satcat_extracted
docker cp /tmp/satcat_extracted/satcat.txt oracledb:/opt/oracle/oradata/
curl -s https://raw.githubusercontent.com/VentechCMS/utilities/master/data_dump.sql > /tmp/data_dump.sql
docker cp /tmp/data_dump.sql oracledb:/tmp/data_dump.sql

docker exec -i oracledb bash -c "sqlplus -S -L / as sysdba <<'SQL'
ALTER SESSION SET CONTAINER = FREEPDB1;
CREATE OR REPLACE DIRECTORY SPACE_OUTPUT_DIR AS '/opt/oracle/oradata';
CREATE OR REPLACE DIRECTORY SDB AS '/opt/oracle/oradata';
CREATE OR REPLACE DIRECTORY SDB_SDB AS '/opt/oracle/oradata';
CREATE OR REPLACE DIRECTORY DATA_DUMP_DIR AS '/opt/oracle/oradata';
GRANT READ, WRITE ON DIRECTORY SPACE_OUTPUT_DIR TO PUBLIC;
GRANT READ, WRITE ON DIRECTORY SDB TO PUBLIC;
GRANT READ, WRITE ON DIRECTORY SDB_SDB TO PUBLIC;
GRANT READ, WRITE ON DIRECTORY DATA_DUMP_DIR TO PUBLIC;
GRANT INHERIT PRIVILEGES ON USER system TO SPACE;
ALTER SESSION SET CURRENT_SCHEMA = SPACE;
@/tmp/data_dump.sql
EXIT
SQL"

docker cp space-master/raw_data/code/space_exporter.pck oracledb:/tmp/space_exporter.pck
docker exec -i oracledb bash -c "sqlplus -S -L / as sysdba <<'SQL'
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = SPACE;
@/tmp/space_exporter.pck
EXIT
SQL"

echo "Done!"
