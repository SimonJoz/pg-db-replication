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
LOG_FILE="../data/logs/tables-restore-data.log"

touch "$LOG_FILE"

# ==============================================================================
# Main - Restore data of given tables
# ==============================================================================

for table in "${TABLES[@]}"; do

  # Create directory
  # =========================================================
  output_dir="$OUTPUT_DIR/${table}_dump"

  # Restore
  # =========================================================

  log "INFO: Restoring table '$table'."

  time pg_restore --data-only --section=data --no-password --verbose --exit-on-error \
    --host="$TARGET_HOST" \
    --port="$TARGET_PORT" \
    --username="$TARGET_USER" \
    --dbname="$TARGET_DB_NAME" \
    --jobs="$NO_OF_JOBS" \
    --format=d "$output_dir" 2>&1 | tee -a "$LOG_FILE"

  log "INFO: Restoring completed for table '$table'."

done
