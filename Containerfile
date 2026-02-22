FROM ubuntu:24.04

USER root
WORKDIR /

ARG UID=1003
ARG GID=1003

# Install packages needed to compile stuff. 
RUN     apt update -y && \
	apt upgrade -y && \
	apt install -y iproute2 ncat vim net-tools dpkg guacd openssl less \
	build-essential \
	libcairo2-dev \
	libjpeg-turbo8-dev \
	libpng-dev \
	libtool-bin \
        uuid-dev \
	libossp-uuid-dev \
	libavcodec-dev \
	libavformat-dev \
	libavutil-dev \
	libswscale-dev \
        freerdp2-dev \
	libpango1.0-dev \
	libssh2-1-dev \
	libvncserver-dev \
	libtelnet-dev \
	libwebsockets-dev \
	libssl-dev \
	libvorbis-dev \
	libwebp-dev \
	libpulse-dev

# Setup the OS like I want and organize the build process
RUN	echo "guacamole:x:1003:1003::/opt/guacamole:/bin/bash" >> /etc/passwd && \
	echo "guacamole:x:1003:" >> /etc/group && \
	echo "tomcat:x:2003:2003::/opt/tomcat9:/bin/bash" >> /etc/passwd && \
	echo "tomcat:x:2003:" >> /etc/group && \
	mkdir /opt/tomcat9  && \
	mkdir /opt/src_downloads  && \
	mkdir /opt/src  && \
        mkdir /app && \
        mkdir /opt/scripts && \
	chown -R tomcat:tomcat /opt/tomcat9


# install java runtime
RUN apt install -y openjdk-17-jdk && dpkg-query -L openjdk-17-jdk > /opt/openjdk-17-jdk-files.log


# Download and compile Guacamole with bash script
COPY guacamole-server-1.6.0.tar.gz /opt/src_downloads
COPY scripts/build_guacamole.bash /opt/scripts
RUN bash /opt/scripts/build_guacamole.bash

RUN mkdir -p /etc/guacamole/ && chown guacamole:guacamole /etc/guacamole

# Download and extract guacamole web interface.
COPY scripts/build_guacamole_client.bash /opt/scripts
RUN  bash /opt/scripts/build_guacamole_client.bash

# Download and extract Tomcat9
COPY scripts/download_tomcat9-src.bash /opt/scripts
RUN bash /opt/scripts/download_tomcat9-src.bash

# ENABLE EXTENSIONS IN GUACAMOLE WEB for AUTHENTICATION methods.
# Each extension needs it's properties set in guacamole.properties
COPY extensions_downloaded/ /app/guacamole-client/
COPY extensions/guacamole-auth-ldap-1.6.0.jar /app/guacamole-client/extensions
COPY extensions/guacamole-auth-header-1.6.0.jar /app/guacamole-client/extensions
COPY extensions/guacamole-auth-jdbc-mysql-1.6.0.jar /app/guacamole-client/extensions
COPY extensions/guacamole-auth-sso-openid-1.6.0.jar /app/guacamole-client/extensions
COPY extensions/guacamole-auth-sso-ssl-1.6.0.jar /app/guacamole-client/extensions
WORKDIR /app/guacamole-client
RUN chown -R guacamole:guacamole /app/guacamole-client/*

COPY guacamole_config/guacamole.properties /app/guacamole-client/guacamole.properties
COPY guacamole_config/user-mapping.xml /app/guacamole-client/user-mapping.xml.disabled
COPY guacamole_config/guacd.conf /app/guacamole/guacd.conf
RUN  ln -s /app/guacamole/guacd.conf /etc/guacamole/guacd.conf
COPY guacamole_config/guacd.conf /app/guacamole/guacd.conf
RUN chmod 644 /app/guacamole-client/guacamole.properties
#RUN chmod 644 /app/guacamole-client/user-mapping.xml
RUN mkdir -p /usr/share/tomcat9 && ln -s /app/guacamole-client /usr/share/tomcat9/.guacamole
RUN mkdir -p /app/guacamole/extenions_downloaded

# Install MySQL Java driver to /app/guacamole-client/lib
COPY mysql-connector-j-9.5.0.jar  /app/guacamole-client/lib


COPY scripts/env.bash /app
COPY scripts/tomcat.service /app
COPY scripts/guacd.service /app
RUN ln -s /app/tomcat.service /app/guacamole-client.service

USER root
EXPOSE 8080
CMD ["/bin/bash"]


# To start the apps run this inside the container: bash /app/env.bash
