#!/bin/bash
set -eux
dnf -y update
dnf -y install nginx
echo "Hello from $(hostname) — ASG behind ALB" > /usr/share/nginx/html/index.html
systemctl enable --now nginx