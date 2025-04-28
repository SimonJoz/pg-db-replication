#!/bin/bash

# ==============================================================================
# Script setup
# ==============================================================================
set -e
source "../config/config.sh"
export PGPASSFILE="../config/.pgpass"

OUTPUT_FILE="../data/counts/count-source-rows.txt"

touch "$OUTPUT_FILE"

# ==============================================================================
# List of tables to query
# ==============================================================================
TABLES=\
(
  "table1"
  "table2"
)

# ==============================================================================
# Main - Count rows in $TABLES from SOURCE db, save to $OUTPUT_FILE
# ==============================================================================
for table in "${TABLES[@]}";
do

 query="SELECT COUNT(*) FROM $table;"

 psql --no-password --echo-all --echo-errors --echo-queries -v ON_ERROR_STOP=1 \
      --host="$SOURCE_HOST" \
      --port="$SOURCE_PORT" \
      --username="$SOURCE_USER" \
      --dbname="$SOURCE_DB_NAME" \
      --log-file="$OUTPUT_FILE" \
      --command="$query"

done
