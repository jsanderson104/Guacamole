#!/bin/bash

podman run -dt --pod GUACAMOLE_APPLICATIONS --name nginx-guac -v ./nginx/nginx.conf:/etc/nginx/nginx.conf -v ./nginx/ssl:/etc/nginx/ssl nginx

