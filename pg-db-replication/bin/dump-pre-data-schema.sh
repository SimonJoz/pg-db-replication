#!/bin/bash

# ==============================================================================
# Script config
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

LOG_FILE="../logs/schema-pre-data-dump.log"
OUTPUT_FILE="../data/schema/schema-pre-data-dump.sql"

touch "$LOG_FILE"
touch "$OUTPUT_FILE"

# ==============================================================================
# Main script - Executes the PRE DATA schema dump.
# Dump results are stored in the $OUTPUT_FILE.
# ==============================================================================

log "INFO: Dumping pre-data schema started."

time pg_dump --schema-only --section=pre-data --no-password --verbose \
  --host="$SOURCE_HOST" \
  --port="$SOURCE_PORT" \
  --username="$SOURCE_USER" \
  --dbname="$SOURCE_DB_NAME" \
  --file="$OUTPUT_FILE" 2>&1 | tee -a "$LOG_FILE"

log "INFO: Dumping pre-data schema completed."
