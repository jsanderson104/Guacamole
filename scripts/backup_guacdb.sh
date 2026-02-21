#!/bin/bash

SQLUSER="root"
SQLPW="guac"
DATE=$(date +%Y-%m-%d_%H%M%S)

# Validate input
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <database_name>"
    exit 1
else
	DB_NAME=$1
fi

OUTPUT_FILE="${DB_NAME}.${DATE}.sql"
echo "Begin export MariaDB: $DB_NAME .... please wait. Depending on DB size this could take a few minutes.."
mysqldump -u$SQLUSER -p$SQLPW -h 127.0.0.1 -P 5306 "$DB_NAME" > "$OUTPUT_FILE"

# Check if the command succeeded
if [ $? -eq 0 ]; then
    echo "Success: Backup created at $OUTPUT_FILE"
else
    echo "Error: mysqldump failed."
    exit 1
fi
