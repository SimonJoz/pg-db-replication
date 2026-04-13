# Source Configuration
# =====================================================================
export SOURCE_HOST="localhost"
export SOURCE_PORT="9000"
export SOURCE_USER="master"
export SOURCE_DB_NAME="db_name"


# Target Configuration
# =====================================================================
export TARGET_HOST="localhost"
export TARGET_PORT="9006"
export TARGET_USER="master"
export TARGET_DB_NAME="db_name"


# Filesystem setup
# =====================================================================
mkdir -p \
"../data/logs" \
"../data/counts" \
"../data/queries" \
"../data/global" \
"../data/schemas" \
"../data/schemas/pre-data" \
"../data/schemas/post-data" \
"../data/tables" \
"../data/tables/data" \
"../data/tables/pre-data" \
"../data/tables/post-data"

# Schemas - Dump globals, pre-data and post-data
# =====================================================================
export SCHEMAS=(
  "schema1"
  "schema2"
)

# Tables - Dumps pre-data, data and post-data
# =====================================================================
export TABLES=(
  "schema.table1"
  "schema.table2"
)
