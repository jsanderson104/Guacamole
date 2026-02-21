#!/bin/bash
# Author: Justin Sanderson, COLSA Corporation
# Purpose: To build a fully-deployable, enterprise-ready, Apache Guacamole solution integrated with MariaDB to provide a Remote Connection Capability that authenticates seamlessly via SSO/SAML/OIDC..

POD="GUACAMOLE_APPLICATIONS"
GUAC_IMAGE_NAME="Gucamole-Custom"
GUACDB="guac"
MARIADB_ROOT_PASSWORD="guac"
MARIADB_USER="guac"  # Not fully implemented below in the SQL import statements.
MARIADB_PW="guac"

podman pod stop $POD 2>/dev/null ; 
podman pod rm $POD 2>/dev/null ; 
podman pod create --name $POD -p 9090:8080 -p 5306:3306

# BUILD our Guacamole Web and GUACD image. Review Containerfile for more in-depth information.
TMPDIR=/home podman build -t ubuntu2404-guac -f Containerfile

# The guacamole-web container is being built from our custom image (Containerfile). Notice the localhost in the tag
# The MariaDB is nothing normal just get the latest from docker.io
podman run -dt --pod $POD --name guacdb-mariadb-pod -e MYSQL_ROOT_PASSWORD=$MARIADB_ROOT_PASSWORD -e MYSQL_USERNAME=$MARIADB_USER -e MYSQL_PASSWORD=$MARIADB_PW -e MYSQL_DATABASE=$GUACDB docker.io/library/mariadb
podman run -dt --pod $POD --name guacamole-web localhost/ubuntu2404-guac:latest

# Use this command only to get a bash prompt. Should just be using the -dt option once an ENTRYPOINT is defined.
#         podman run -it --pod $POD --name guacamole-web localhost/ubuntu2404-guac:latest

echo "Sleeping.... Waiting on Containers to start"
echo "Gotta give MariaDB some time to start and make the DB we asked the container to make us above."
sleep 15

# Create the "guac" MariaDB database and grant access to our application db user/pass to only that database.
# Don't need to make the database because we defined the container to make it for us above, but to do it manually --> mysql -uroot -pguac -h 127.0.0.1 -P 5306 -e "create database $GUACDB"
mysql -uroot -pguac -h 127.0.0.1 -P 5306 -e  " create user 'guac'@'localhost' identified by 'guac' "
mysql -uroot -pguac -h 127.0.0.1 -P 5306 -e  " create user 'guac'@'127.0.0.1' identified by 'guac' "
mysql -uroot -pguac -h 127.0.0.1 -P 5306 -e " grant all privileges on $GUACDB.* to 'guac'@'127.0.0.1' "
mysql -uroot -pguac -h 127.0.0.1 -P 5306 -e " flush privileges "

# Import the Guacamole-specific Database Files (for a new instance/mariadb-container only) do NOT do this on a PROD instance
mysql -uroot -pguac -h 127.0.0.1 -P 5306 $GUACDB < guacamole_db_setup_files/001-create-schema.sql

# Creates default admin user by modifying the guacamole_identity and guacamole_user, and guacamole_system_permissions tables in the database.
mysql -uroot -pguac -h 127.0.0.1 -P 5306 $GUACDB < guacamole_db_setup_files/002-create-admin-user.sql

