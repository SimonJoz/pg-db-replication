#!/bin/bash

# ==============================================================================
# Script config
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

LOG_FILE="../logs/global-objects-dump.log"
OUTPUT_FILE="../data/schema/global-objects-dump.sql"

touch "$LOG_FILE"
touch "$OUTPUT_FILE"

# ==============================================================================
# Main - Dump the global objects into the $OUTPUT_FILE
# ==============================================================================

log "INFO: Dumping global objects started."

time pg_dumpall --globals-only --no-role-passwords --verbose --no-password \
  --host="$SOURCE_HOST" \
  --port="$SOURCE_PORT" \
  --username="$SOURCE_USER" \
  --dbname="$SOURCE_DB_NAME" \
  --file="$OUTPUT_FILE" 2>&1 | tee -a "$LOG_FILE"

log "INFO: Dumping global objects completed."
