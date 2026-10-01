#!/bin/bash
# This script is intended to be executed via a Jenkins job shell method to start the process of building a Guacamole container image on a Jenkins node that has podman installed.
# The end of this build will tag and upload the result image to docker.io/jsanderson104/guacamole-k8s:mariadb-1.6.0
# There's a similar file in this repo "build-guacamole-image.bash" that will build a guacamole container image ( through a separate Jenkins job but using same repo) that already has the webui/tomcat and guacd running.

podman build -t mariadb-guac160 -f Containerfile

# Find my Linux UID
MYUID=$(getent passwd $(whoami) | cut -d: -f3)

# Set Docker.io registry creds so I can push image
cp /home/podman-builder/workspace/Build-Nginx-Image/auth.json /run/user/$MYUID/containers/auth.json

podman login docker.io || exit 1

podman tag mariadb-guac160 mariadb-guac160:latest
podman push localhost/mariadb-guac160:latest docker.io/jsanderson104/guacamole-k8s:mariadb-guac160
