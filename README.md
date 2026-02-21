=============================== GUACAMOLE BUILD PROJECT NOTES AND HOW TO =========================================
# General information about this configuration and the image used.
# 1. The container is being built with GUACD already precompiled and configured inside the image.
# 2. The image is being built with Tomcat already download and ready to go.
# 3. The Guacamole "client" which is actually the WebUI is downloaded and ready to go.
# 4. Most everything is located in /app. 
# 5. There are a few (2 or 3) occassions where I was forced to use a symbolic link.
# 6. All of this is expected to be run in a POD so the MariaDB container can easily talk to the Guacamole container we start from the image we build.
# 7. There's nothing special about the MariaDB version that I'm using.
# 8. Setting up the DB for guacamole involves a few steps and is simple once you know where to look.. described in detail below.
# 9. I don't precompile GUACD on the host. I do it inside the image after running the apt commands to update the container and install the build packages needed
# 10. I also apt installed netcat, netstat, and the IP commands to make tshooting easier.
# 11. The image is a little bloated b/c of #9 & #10
# 12. Src data to do most of the building and configuring is copied into the image (inherently the container) in /opt

# Use the script to build the image then start an ephemeral container and attach to it for building/modifying purposes it drops to a bash shell and doesn't start the application
cmd ot run on the container host shell-->  bash rebuild.bash

------------- Rebuild the image manually with this command -------
# You need to be in the same directory as the Containerfile b/c there are a lot of accopmanying files it needs to use in the build process
podman build -t [sometagname] -f Containerfile .


------------  Make a POD to put our 2 containers in (they'll share the same loopback address which is great) ---------------
podman pod create --name GUACAMOLE_APPLICATIONS -p 9090:8080 -p 5306:3306



# ALL OF THE AUTH EXTENSIONS CAN BE DOWNLOADED FROM HERE: https://guacamole.apache.org/releases/1.6.0/
# Note: The extensions must match the guacamole-client version (guacamole-client -aka- the web interface WAR file launched by tomcat/webapps/*.war)

# The SQL schema import files for Guacamole database are located in the guacamole-auth-jdbc-1.6.0.tar.gz file:  001-*.sql & 002*.sql both need to be executed on the mariadb you have configured in the
# guacamole.properties file. 
# There are also some upgrade scripts in there for future reference (ie - if guacamole gets upgraded to 1.6.1 then they should supply a sql file IF the schema changes in the db.
# NOTE: The needed SQL files, I have extracted and placed in ./guacamole_db_setup_files/ directory.

---------------- User Mapping and Authentication extension info-------------
# If the /app/guacamole-client/user-mapping.xml file exists - it will always be included in the config on startup.
# The parameter/option to define this file seems to be ignored unless maybe it's a way to define an alternate location.
# The file that I have creates a guacadmin user and 2 client connections configured but does NOT give the guacadmin user actual administrative permissions. 
# The Guacamole recommended method with MySQL -AND- LDAP combination is to use ldap for authentication AND mysql to store all other data for guacamole (like client connections, etc.).
# Note: that the ldap "id"/"username" attribute must match exactly the username in the mysql guacamole_entity table

# If using SAML authentication and MySQL then SAML will automatically create the username in MySQL for you... this is different behavior than the LDAP extension.

---------- START/STOP SCRIPTS FOR HANDLING SERVICES ------------
# Made scripts using Google AI to make some proper SysV init scripts for guacd and tomcat.   /app/guacd.service and /app/tomcat.service respectively.
# Changed the env.bash script to just call the 2 scripts above to start the applications at container runtime.

 ------ ADDING THE MYSQL JDBC JAVA driver to the Guacamole Client (Web UI) container ---------
# Setting up MySQL authentication and driver can be a little tricky. It took me a while to figure it out... 
# Guacamole-client war file doesnt' include the needed JDBC driver file.
# Download it manually from https://downloads.mysql.com/archives/c-j/ and select "Platform Independent" to get the needed .jar file.
# The .jar file is the Tomcat JDBC MySQL driver.
# So for the Guacamole web interface we had to put this driver jar file in $GUACAMOLE_HOME/lib (in our case, /app/guacamole-client/lib)


----------- GUACD config ----------
# Note: The guacd.conf file MUST be placed in /etc/guacamole/guacd.conf or use a sym link to point it to another location like in this container setup.
# The basic guacd.conf file can be retrieved from this article https://stackoverflow.com/questions/72316256/connection-refused-between-tomcat-and-guacamoleguacd-server-apache-guacamole
# ALSO NOTE: by default GUACD listens on IPV6 only if you don't define in the guacd.conf the "bind_address" to "127.0.0.1" or "localhost", it'll start up on IPV6 which is retarded.


### RUNNING THE MARIADB INSIDE A POD ####
# Note: We don't define a port to expose on the container when we're putting it in a pod. The pod should be created with the exposed ports, not the container.
podman run -dt --pod GUACAMOLE_APPLICATIONS --name guacdb-mariadb-pod -e MYSQL_ROOT_PASSWORD=guac -e MYSQL_USERNAME=guac -e MYSQL_PASSWORD=guac -e MYSQL_DATABASE=guac docker.io/library/mariadb

 ----------Creating and setting up the Guacamole Database container as well as the Guacamole DB initial data load ----------
# Get a MySQL db container running and connect to it, in the container example, we're using a POD so the db container and the tomcat container are on the sanme IP (pretty cool).
# We could use this command to connect to the MYSQL instance: 

# We need these commands to ran before attempting to import the 2 SQL guacamole files provided in guacamole-auth-extension-jdbc.tar.gz file..
NOTE: the database name is used in the guacamole.properties file so make sure they match and
	# Also make sure the sql username/pass combination we're about to make in the MariaDB container/instance matches the guacamole.properties file.
	# The next few commands are being ran from the podman host therefore I'm using port 5306 instead (exposed when pod was created). If, perhaps, you're attached/inside of the guacamole container we built (which should be running in a pod) you can remove the -P option and use default 3306
	# mysql -uroot -pguac -h 127.0.0.1 -P 5306 -e "create database guac" 
	# mysql -uroot -pguac -h 127.0.0.1 -P 5306 -e  " create user 'guac'@'localhost' identified by 'guac' "
	# mysql -uroot -pguac -h 127.0.0.1 -P 5306 -e  " create user 'guac'@'127.0.0.1' identified by 'guac' "
	# mysql -uroot -pguac -h 127.0.0.1 -P 5306 -e " grant all privileges on guac.* to 'guac'@'127.0.0.1' "
	# mysql -uroot -pguac -h 127.0.0.1 -P 5306 -e " flush privileges "

	Next, you'll need to import the 2 SQL files that guacamole provides in their tar.gz file: also already extracted for ease at ./guacamole_db_setupfiles/
		a) 001-schema.sql
		b) 002-guacadmin_user.sql
			* user/pass = guacadmin/guacadmin
