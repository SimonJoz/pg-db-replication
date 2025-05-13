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
"../logs" \
"../data/counts" \
"../data/dumps" \
"../data/schema/pre-data" \
"../data/schema/post-data"
