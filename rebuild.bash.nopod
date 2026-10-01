#!/bin/bash

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
