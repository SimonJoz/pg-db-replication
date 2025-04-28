#!/bin/bash

# ==============================================================================
# Script setup
# ==============================================================================
set -e
source "../config/config.sh"
source "../lib/functions.sh"
export PGPASSFILE="../config/.pgpass"


LOG_FILE="../logs/<log_file_name>.log"

# PgSQL server configuration
# =====================================================================
PORT="5432"
HOST="<host>"
USER="<user>"
DB_NAME="<db_name>"


# =====================================================================
# Files containing SQL queries to run
# =====================================================================
INPUT_FILES=\
(
  "my_file.sql"
)

# =====================================================================
# Main
# =====================================================================
for input_file in "${INPUT_FILES[@]}";
do

  psql --no-password --echo-all --echo-errors --echo-queries -v ON_ERROR_STOP=1 \
    --host="$HOST" \
    --port="$PORT" \
    --username="$USER" \
    --dbname="$DB_NAME" \
    --log-file="$LOG_FILE" \
    --file="$input_file"

done
