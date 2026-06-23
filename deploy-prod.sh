#!/bin/bash
set -e

PROD_HOST="85.215.136.154"
PROD_USER="root"
SSH_KEY="$HOME/.ssh/id_rsa"
WEBAPPS="/opt/tomcat/webapps"

echo "==> Build..."
./mvnw clean package -q

echo "==> Deploy nach $PROD_HOST..."
scp -i "$SSH_KEY" target/MyBlog.war "$PROD_USER@$PROD_HOST:$WEBAPPS/MyBlog.war"

echo "==> Fertig. Tomcat deployed automatisch."
