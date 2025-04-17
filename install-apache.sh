#!/bin/bash
sudo -su
yum update -y
yum install -y httpd
systemctl enable httpd
start httpd
echo "<html><body><h1>WEB TIER SUCCESS"</h1></body><html>" > /var/www/html/index.html