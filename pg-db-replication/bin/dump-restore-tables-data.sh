#!/bin/bash

# ==============================================================================
# Script config
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

NO_OF_DUMP_JOBS=1
NO_OF_RESTORE_JOBS=1

OUTPUT_DIR="../data/dumps"
LOG_FILE="../logs/dump-restore-data.log"

touch "$LOG_FILE"

# ==============================================================================
# List of tables/partitions to dump and restore
# ==============================================================================
TABLES=\
(
  "table1"
  "table2"
)

# ==============================================================================
# Main script execution - Perform dump and restore of given tables.
# ==============================================================================

for table in "${TABLES[@]}"; do
  log "INFO: Process started."

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
    --jobs="$NO_OF_DUMP_JOBS" \
    --compress=0 --format=d --file="$output_dir" 2>&1 | tee -a "$LOG_FILE"

  log "INFO: Dumping completed in for table '$table'."

  # Restore
  # =========================================================

  log "INFO: Restoring table '$table'."

  time pg_restore --data-only --section=data --no-password --verbose --exit-on-error \
    --host="$TARGET_HOST" \
    --port="$TARGET_PORT" \
    --username="$TARGET_USER" \
    --dbname="$TARGET_DB_NAME" \
    --jobs="$NO_OF_RESTORE_JOBS" \
    --format=d --file="$output_dir" 2>&1 | tee -a "$LOG_FILE"

  log "INFO: Restoring completed for table '$table'."

  # Clean up
  # =========================================================

  rm -r "$output_dir"

  # =========================================================

  log "INFO: Process completed."
done
