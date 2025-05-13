#!/bin/bash

# ==============================================================================
# Script setup
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"

LOG_FILE="../logs/queries-in-target-$(date '+%y-%m-%d-%H:%M:%S' ).log"

touch "$LOG_FILE"

# =====================================================================
# Files containing SQL queries to run
# =====================================================================
INPUT_FILES=\
(
  "../data/schema/filename.sql"
)

# =====================================================================
# Main
# =====================================================================
for input_file in "${INPUT_FILES[@]}";
do

  psql --no-password --echo-all --echo-errors --echo-queries -v ON_ERROR_STOP=1 \
    --host="$TARGET_HOST" \
    --port="$TARGET_PORT" \
    --username="$TARGET_USER" \
    --dbname="$TARGET_DB_NAME" \
    --log-file="$LOG_FILE" \
    --file="$input_file"

done
