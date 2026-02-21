#!/bin/bash

SQLUSER="root"
SQLPW="guac"


# Validate input
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <database_name> <sqlfile>"
    exit 1
else
	DB_NAME=$1
	IMPORT=$2
fi

echo "Begin import MariaDB: $DB_NAME .... please wait. Depending on DB size this could take a few minutes.."
mysql -u$SQLUSER -p$SQLPW -h 127.0.0.1 -P 5306 "$DB_NAME" < $IMPORT

# Check if the command succeeded
if [ $? -eq 0 ]; then
    echo "Success: Import Successful to $DB_NAME"
else
    echo "Error: mysqlimport failed."
    exit 1
fi
