#!/bin/bash

# ==============================================================================
# Script config
# ==============================================================================
set -e
source "../config/config.sh"
export PGPASSFILE="../config/.pgpass"

OUTPUT_FILE="../data/counts/target-rows-count_$(date +"%Y-%m-%d %H:%M:%S").sql"

touch "$OUTPUT_FILE"

# ==============================================================================
# Main - Count rows in $TABLES from TARGET db, save to $OUTPUT_FILE
# ==============================================================================
for table in "${TABLES[@]}";
do

 query="SELECT COUNT(*) FROM $table;"

 psql --no-password --echo-all --echo-errors --echo-queries -v ON_ERROR_STOP=1 \
      --host="$TARGET_HOST" \
      --port="$TARGET_PORT" \
      --username="$TARGET_USER" \
      --dbname="$TARGET_DB_NAME" \
      --log-file="$OUTPUT_FILE" \
      --command="$query"

done
