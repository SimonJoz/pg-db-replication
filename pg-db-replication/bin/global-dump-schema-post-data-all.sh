#!/bin/bash

# ==============================================================================
# Script config
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

LOG_FILE="../logs/global-dump-schema-post-data-all.log"
OUTPUT_FILE="../data/global/global-dump-schema-post-data-all.log"

touch "$LOG_FILE" "$OUTPUT_FILE"

# ==============================================================================
# Main - Dump the POST DATA schema into the $OUTPUT_FILE
# ==============================================================================

log "INFO: Dumping post-data for all schemas started."

time pg_dump --schema-only --section=post-data --no-password --verbose \
  --host="$SOURCE_HOST" \
  --port="$SOURCE_PORT" \
  --username="$SOURCE_USER" \
  --dbname="$SOURCE_DB_NAME" \
  --file="$OUTPUT_FILE" 2>&1 | tee -a "$LOG_FILE"

log "INFO: Dumping post-data for all schemas completed."
