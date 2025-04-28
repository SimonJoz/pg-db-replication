#!/bin/bash

# ==============================================================================
# Script config
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

NO_OF_JOBS=8

OUTPUT_DIR="../data/dumps"
LOG_FILE="../logs/dump-tables-data.log"

touch "$LOG_FILE"

# ==============================================================================
# List of tables/partitions to dump
# ==============================================================================
TABLES=\
(
  "table1"
  "table2"
)

# ==============================================================================
# Main - Dump data of given tables
# ==============================================================================

for table in "${TABLES[@]}"; do

  # Create directory
  # =========================================================
  output_dir="$OUTPUT_DIR/${table}_dump"
  mkdir -p "$output_dir"

  # Dump
  # =========================================================
  log "INFO: Dumping table '$table'."

  time pg_dump --data-only --section=data --no-password --verbose \
    --host="$SOURCE_HOST" \
    --port="$SOURCE_PORT" \
    --username="$SOURCE_USER" \
    --dbname="$SOURCE_DB_NAME" \
    --table="$table"  \
    --jobs="$NO_OF_JOBS" \
    --compress=0 --format=d --file="$output_dir" 2>&1 | tee -a "$LOG_FILE"

  log "INFO: Dumping completed in for table '$table'."

done
