#!/bin/bash

VER="9.0.115"
DLURL="https://dlcdn.apache.org/tomcat/tomcat-9/v${VER}/bin/apache-tomcat-${VER}.tar.gz"
DLDIR=/opt/src_downloads

mkdir -p $DLDIR 2>/dev/null; cd $DLDIR && wget $DLURL
tar -C /app -xzf apache-tomcat-${VER}.tar.gz

# Link /app/tomcat for ease-of-use / laziness
ln -s /app/apache-tomcat-${VER} /app/tomcat


cp /app/guacamole-client/guacamole-client-1.6.0.war /app/tomcat/webapps/guacamole.war
echo "GUACAMOLE_HOME=/app/guacamole-client" >> /etc/default/tomcat9
