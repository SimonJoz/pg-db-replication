#!/bin/bash

# ==============================================================================
# Script config
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

LOG_FILE="../data/logs/schemas-dump-pre-data.sh"
OUTPUT_DIR="../data/schemas"

touch "$LOG_FILE"

# ==============================================================================
# Main - Dump the configured schemas PRE DATA into the $OUTPUT_FILE
# ==============================================================================

for schema in "${SCHEMAS[@]}"; do
  log "INFO: Dumping pre-data for configured schema: ${schema}"

  output_file="$OUTPUT_DIR/${schema}-pre-data-dump.sql"

  time pg_dump --schema-only --section=pre-data --no-password --verbose \
    --host="$SOURCE_HOST" \
    --port="$SOURCE_PORT" \
    --username="$SOURCE_USER" \
    --dbname="$SOURCE_DB_NAME" \
    --schema="$schema" \
    --file="$output_file" 2>&1 | tee -a "$LOG_FILE"

    log "INFO: Dumping pre-data of configured schema '${schema}' completed."
done
