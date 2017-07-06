#!/usr/bin/env bash

function log() {
  echo "[$(date -Iseconds)] $1"
}

function timestamp() {
  date +%s
}

# Set proper variable names for options
s3_path=$1
db_name=$2

# Set up default options
PG_HOST="${PG_HOST:-pg}"
PG_PORT="${PG_PORT:-5432}"
PG_USER="${PG_USER:-postgres}"

# Set up ~/.pgpass
echo "${PG_HOST}:${PG_PORT}:*:${PG_USER}:${PG_PASS}" > ~/.pgpass
chmod 0600 ~/.pgpass

# Informational output
log "Connecting to PostgreSQL server ${PG_HOST}:${PG_PORT} as user ${PG_USER}"

# Dump databases
filename="${db_name}-$(timestamp).sql"
log "Dumping database \"${db_name}\""
pg_dump --file /tmp/$filename \
        --host $PG_HOST \
        --port $PG_PORT \
        --user $PG_USER \
        $db_name
log "Done dumping database"

# Create archive
archive=${filename}.tar.gz
archive_path=/tmp/${archive}
tar -czf $archive_path -C /tmp $filename
log "Created archive ${archive}"

# Configure AWS CLI
cat > ~/.aws/config << EOF
[default]
output = text
region = $AWS_REGION
EOF

cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id = $AWS_ACCESS_KEY
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOF

# Upload to AWS
s3_path="s3://${s3_path}/${archive}"
log "Uploading archive to ${s3_path}"
aws s3 cp $archive_path $s3_path --quiet
log "Archive succesfully uploaded"
