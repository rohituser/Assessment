#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y
systemctl enable nginx
systemctl start nginx
echo "<h1>Welcome to DevOps Assessment</h1>" > /usr/share/nginx/html/index.html
