#!/bin/bash
# This script is intended to be executed via a Jenkins job shell method to start the process of building a Guacamole container image on a Jenkins node that has podman installed.
# The end of this build will tag and upload the result image to docker.io/jsanderson104/guacamole-k8s
# There's a similar file in this repo "build-mariadb-image.bash" that will build a mariadb container image ( through a separate Jenkins job but using same repo) that already has the db created and the tables/schema imported as well as an admin account.

# Set the Buildah temp directory to home instead of /var/tmp which has little space.Not running as root so this wont work due to perms on /home for avg user.
#TMPDIR=/home podman build -t ubuntu2404-guac -f Containerfile

podman build -t ubuntu2404-guac -f Containerfile

# Don't need to run it unless I'm building/debugging
#podman run -it  -p 9090:8080 --rm localhost/ubuntu2404-guac:latest

# Find my Linux UID
MYUID=$(getent passwd $(whoami) | cut -d: -f3)

# Set Docker.io registry creds so I can push image
cp /home/podman-builder/workspace/Build-Nginx-Image/auth.json /run/user/$MYUID/containers/auth.json

podman login docker.io || exit 1

podman tag ubuntu2404-guac ubuntu2404-guac:latest
podman push localhost/ubuntu2404-guac:latest docker.io/jsanderson104/guacamole-k8s:v1
