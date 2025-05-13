#!/bin/bash

# ==============================================================================
# Script setup
# ==============================================================================
set -e
source "../config/config.sh"
export PGPASSFILE="../config/.pgpass"


NOW=$(date '+%y-%m-%d-%H-%M-%S')
LOG_FILE="../logs/migrate-tables-$NOW.log"
SOURCE_COUNTS_FILE="../data/counts/count-source-rows-$NOW.txt"
TARGET_COUNTS_FILE="../data/counts/count-target-rows-$NOW.txt"

touch "$SOURCE_COUNTS_FILE" "$TARGET_COUNTS_FILE"


# ==============================================================================
# List of tables to query
# ==============================================================================
TABLES=\
(
  "table1"
  "table2"
)


# ==============================================================================
# Count rows in SOURCE db. Save results in SOURCE_COUNTS_FILE
# ==============================================================================
for table in "${TABLES[@]}";
do

 query="SELECT COUNT(*) FROM $table;"

 psql --no-password --echo-all --echo-errors --echo-queries -v ON_ERROR_STOP=1 \
      --host="$SOURCE_HOST" \
      --port="$SOURCE_PORT" \
      --username="$SOURCE_USER" \
      --dbname="$SOURCE_DB_NAME" \
      --log-file="$SOURCE_COUNTS_FILE" \
      --command="$query"
done


# ==============================================================================
# Dump pre-data schemas. Save it under ../data/schema/pre-data/
# ==============================================================================
for table in "${TABLES[@]}";
do

  output_file="../data/schema/pre-data/$table-pre-data-schema-dump.sql"
  touch "$output_file"

  log "INFO: Initiating the pre-data schema dump for table: $table."

  time pg_dump --schema-only --section=pre-data --no-password --verbose \
    --host="$SOURCE_HOST" \
    --port="$SOURCE_PORT" \
    --username="$SOURCE_USER" \
    --dbname="$SOURCE_DB_NAME" \
    --table="$table"  \
    --file="$output_file" 2>&1 | tee -a "$LOG_FILE"

  log "INFO: Completed pre-data schema dump for table: $table."

done


# ==============================================================================
# Dump post-data schemas. Save it under ../data/schema/post-data/
# ==============================================================================
for table in "${TABLES[@]}";
do

  output_file="../data/schema/post-data/$table-post-data-schema-dump.sql"
  touch "$output_file"

  log "INFO: Initiating the post-data schema dump for table: $table."

  time pg_dump --schema-only --section=post-data --no-password --verbose \
    --host="$SOURCE_HOST" \
    --port="$SOURCE_PORT" \
    --username="$SOURCE_USER" \
    --dbname="$SOURCE_DB_NAME" \
    --table="$table"  \
    --file="$output_file" 2>&1 | tee -a "$LOG_FILE"

  log "INFO: Completed post-data schema dump for table: $table."

done

# =====================================================================
# Restore pre data schemas in TARGET db.
# =====================================================================
PRE_DATA_FILES=$(ls ../data/schema/pre-data/*.sql)

for sql_file in "${PRE_DATA_FILES[@]}";
do

  psql --no-password --echo-all --echo-errors --echo-queries -v ON_ERROR_STOP=1 \
    --host="$TARGET_HOST" \
    --port="$TARGET_PORT" \
    --username="$TARGET_USER" \
    --dbname="$TARGET_DB_NAME" \
    --log-file="$LOG_FILE" \
    --file="$sql_file"

done

# ==============================================================================
# Main script execution.
# 1. Perform data dump from SOURCE db to ../data/dumps.
# 2. Restore table in TARGET db and removes dumped data.
# ==============================================================================

for table in "${TABLES[@]}"; do
  log "INFO: Process started."

  output_dir="../data/dumps/${table}_dump"
  mkdir -p "$output_dir"

  # Dump
  # =========================================================
  log "INFO: Dumping table '$table'."

  time pg_dump --data-only --section=data --no-password --verbose \
    --host="$SOURCE_HOST" \
    --port="$SOURCE_PORT" \
    --username="$SOURCE_USER" \
    --dbname="$SOURCE_DB_NAME" \
    --table="$table"  \
    --jobs="$NO_OF_DUMP_JOBS" \
    --compress=0 --format=d --file="$output_dir" 2>&1 | tee -a "$LOG_FILE"

  log "INFO: Dumping completed in for table '$table'."

  # Restore
  # =========================================================

  log "INFO: Restoring table '$table'."

  time pg_restore --data-only --section=data --no-password --verbose --exit-on-error \
    --host="$TARGET_HOST" \
    --port="$TARGET_PORT" \
    --username="$TARGET_USER" \
    --dbname="$TARGET_DB_NAME" \
    --jobs="$NO_OF_RESTORE_JOBS" \
    --format=d --file="$output_dir" 2>&1 | tee -a "$LOG_FILE"

  log "INFO: Restoring completed for table '$table'."

  # Clean up
  # =========================================================

  rm -r "$output_dir"

  log "INFO: Process completed."

done


# =====================================================================
# Restore post data schemas in TARGET db.
# =====================================================================
POST_DATA_FILES=$(ls ../data/schema/post-data/*.sql)

for sql_file in "${POST_DATA_FILES[@]}";
do

  psql --no-password --echo-all --echo-errors --echo-queries -v ON_ERROR_STOP=1 \
    --host="$TARGET_HOST" \
    --port="$TARGET_PORT" \
    --username="$TARGET_USER" \
    --dbname="$TARGET_DB_NAME" \
    --log-file="$LOG_FILE" \
    --file="$sql_file"

done


# ==============================================================================
# Count rows in TARGET db. Save results in TARGET_COUNTS_FILE
# ==============================================================================
for table in "${TABLES[@]}";
do

 query="SELECT COUNT(*) FROM $table;"

 psql --no-password --echo-all --echo-errors --echo-queries -v ON_ERROR_STOP=1 \
      --host="$TARGET_HOST" \
      --port="$TARGET_PORT" \
      --username="$TARGET_USER" \
      --dbname="$TARGET_DB_NAME" \
      --log-file="$TARGET_COUNTS_FILE" \
      --command="$query"

done
