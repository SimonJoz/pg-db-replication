#!/bin/bash

# ==============================================================================
# Script setup
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

OUTPUT_DIR="../data/tables/pre-data"
LOG_FILE="../logs/tables-dump-pre-data.log"

touch "$LOG_FILE"

# ==============================================================================
# Main - Dump the PRE DATA of configured $TABLES to $output_file.
# ==============================================================================
for table in "${TABLES[@]}";
do

  output_file="$OUTPUT_DIR/$table-pre-data-dump.sql"
  touch "$output_file"

  log "INFO: Initiating the pre-data schema dump for table: $table."

  time pg_dump --schema-only --section=pre-data --no-password --verbose \
    --host="$SOURCE_HOST" \
    --port="$SOURCE_PORT" \
    --username="$SOURCE_USER" \
    --dbname="$SOURCE_DB_NAME" \
    --table="$table"  \
    --file="$output_file" 2>&1 | tee -a "$LOG_FILE"

  log "INFO: Completed pre-data schema dump for table: $table."

done




