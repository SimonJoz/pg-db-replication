#!/bin/bash

# ==============================================================================
# Script config
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

LOG_FILE="../data/logs/schemas-dump-post-data.log"
OUTPUT_FILE="../data/schemas/schemas-post-data-dump.sql"

touch "$LOG_FILE"
touch "$OUTPUT_FILE"

# ==============================================================================
# Main - Dump the POST DATA schema into the $OUTPUT_FILE
# ==============================================================================

log "INFO: Dumping post-data for configured schemas started."

SCHEMA_ARGS=()

for schema in "${SCHEMAS[@]}"; do
  SCHEMA_ARGS+=(--schema="$schema")
done

time pg_dump --schema-only --section=post-data --no-password --verbose \
  --host="$SOURCE_HOST" \
  --port="$SOURCE_PORT" \
  --username="$SOURCE_USER" \
  --dbname="$SOURCE_DB_NAME" \
  "${SCHEMA_ARGS[@]}" \
  --file="$OUTPUT_FILE" 2>&1 | tee -a "$LOG_FILE"

log "INFO: Dumping post-data for configured schemas completed."
