#!/bin/bash

# ==============================================================================
# Script config
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

LOG_FILE="../logs/global-dump-objects.log"
OUTPUT_FILE="../data/global/global-objects-dump.sql"

touch "$LOG_FILE" "$OUTPUT_FILE"

# ==============================================================================
# Main - Dump the global objects into the $OUTPUT_FILE
# ==============================================================================

log "INFO: Dumping global objects started."

time pg_dumpall --globals-only --no-role-passwords --verbose --no-password \
  --host="$SOURCE_HOST" \
  --port="$SOURCE_PORT" \
  --username="$SOURCE_USER" \
  --file="$OUTPUT_FILE" 2>&1 | tee -a "$LOG_FILE"

log "INFO: Dumping global objects completed."
