#!/bin/bash

CACHEDIR="/srv/www/apt"
PKGREPO_URL="http://archive.ubuntu.com/ubuntu/pool/main/"

function init_cachedirs() {
  # create dirs for package cache
  echo -n "initializing cache directories... "

  mkdir -p ${CACHEDIR}/debian
  mkdir -p ${CACHEDIR}/debian-security

  # create top-level directories for ubuntu as nginx will not create them recursively
  cd /tmp/
  wget --force-directories -r --level=1 -R '*.html*,*.gif' --quiet $PKGREPO_URL
  mv archive.ubuntu.com/* /srv/www/apt/
  
  chown nginx. -R /srv/www/apt
  echo "done"
}

[ -d $CACHEDIR ] || init_cachedirs

RESOLVER=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | head -1)
sed "s|_RESOLVER_|$RESOLVER|g;s|_CACHEDIR_|$CACHEDIR|g" /nginx-template.conf > /etc/nginx/nginx.conf

/usr/sbin/nginx -c /etc/nginx/nginx.conf
