These scripts are to be placed inside the container and ran during the Image build.

Snippet from the Containerfile being used to build the image for Apache Guacamole 1.6.0

---- begin snippet ------
# Download and compile Guacamole with bash script
COPY scripts/build_guacamole.bash /opt/scripts
RUN bash /opt/scripts/build_guacamole.bash

# Download and extract Tomcat9
COPY scripts/download_tomcat9-src.bash /opt/scripts
RUN bash /opt/scripts/download_tomcat9-src.bash
---- end snippet ------
