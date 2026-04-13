#!/bin/bash

# ==============================================================================
# Script config
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

LOG_FILE="../data/logs/schemas-dump-pre-data.sh"
OUTPUT_FILE="../data/schemas/schemas-pre-data-dump.sql"

touch "$LOG_FILE"
touch "$OUTPUT_FILE"

# ==============================================================================
# Main - Dump the configured schemas PRE DATA into the $OUTPUT_FILE
# ==============================================================================

log "INFO: Dumping pre-data of configured schemas started."

SCHEMA_ARGS=()

for schema in "${SCHEMAS[@]}"; do
  SCHEMA_ARGS+=(--schema="$schema")
done

time pg_dump --schema-only --section=pre-data --no-password --verbose \
  --host="$SOURCE_HOST" \
  --port="$SOURCE_PORT" \
  --username="$SOURCE_USER" \
  --dbname="$SOURCE_DB_NAME" \
  "${SCHEMA_ARGS[@]}" \
  --file="$OUTPUT_FILE" 2>&1 | tee -a "$LOG_FILE"

log "INFO: Dumping pre-data of configured schemas completed."
