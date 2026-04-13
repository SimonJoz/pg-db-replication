#!/bin/bash

# ==============================================================================
# Script config
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

NO_OF_JOBS=8

OUTPUT_DIR="../data/tables/data"
LOG_FILE="../data/logs/tables-dump-data.log"

touch "$LOG_FILE"

# ==============================================================================
# Main - Dump data of configured tables
# ==============================================================================

for table in "${TABLES[@]}"; do

  # Create directory
  # =========================================================
  output_dir="$OUTPUT_DIR/${table}_dump"
  mkdir -p "$output_dir"

  # Dump
  # =========================================================
  log "INFO: Dumping data from: '$table'."

  time pg_dump --data-only --section=data --no-password --verbose \
    --host="$SOURCE_HOST" \
    --port="$SOURCE_PORT" \
    --username="$SOURCE_USER" \
    --dbname="$SOURCE_DB_NAME" \
    --table="$table"  \
    --jobs="$NO_OF_JOBS" \
    --compress=0 --format=d --file="$output_dir" 2>&1 | tee -a "$LOG_FILE"

  log "INFO: Dumping data from: '$table' completed."

done
