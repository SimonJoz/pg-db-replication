#!/bin/bash

# ==============================================================================
# Script setup
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

LOG_FILE="../logs/tables-dump-post-data.log"

touch "$LOG_FILE"

# ==============================================================================
# Main - Dump the POST DATA of configured $TABLES, to $output_file.
# ==============================================================================
for table in "${TABLES[@]}";
do

  output_file="../data/schema/post-data/$table-post-data-dump.sql"
  touch "$output_file"

  log "INFO: Initiating the post-data schema dump for table: $table."

  time pg_dump --schema-only --section=post-data --no-password --verbose \
    --host="$SOURCE_HOST" \
    --port="$SOURCE_PORT" \
    --username="$SOURCE_USER" \
    --dbname="$SOURCE_DB_NAME" \
    --table="$table"  \
    --file="$output_file" 2>&1 | tee -a "$LOG_FILE"

  log "INFO: Completed post-data schema dump for table: $table."

done
