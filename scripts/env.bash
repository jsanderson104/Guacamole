#!/bin/bash
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
GUACAMOLE_HOME=/app/guacamole-client
PATH=$PATH:/app/tomcat/bin:/app/guacamole/sbin:/app/guacamole/bin:/app/tomcat/bin

#/app/tomcat/bin/startup.sh
#/app/guacamole/sbin/guacd -L debug 

bash /app/tomcat.service start > /dev/stdout
bash /app/guacd.service start > /dev/stdout

while pgrep "java" >/dev/null || pgrep -x "guacd" >/dev/null; do
    sleep 1
done
