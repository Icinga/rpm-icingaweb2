#!/bin/bash
# this script runs in the rpm_test environment

install_package icingaweb2

# set timezone for PHP
if [ -d /etc/php.d ]; then
  php_d=/etc/php.d
elif [ -d /etc/php5/conf.d ]; then
  php_d=/etc/php5/conf.d
else
  echo "Can not set PHP timezone!" >&2
  exit 1
fi
echo "date.timezone = UTC" >${php_d}/timezone.ini

# Start apache in background
if [ -x /usr/sbin/httpd ]; then
  sudo httpd -t
  sudo httpd -k start
elif [ -x /usr/sbin/apache2 ]; then
  sudo apache2 -t
  sudo apache2 -k start
else
  echo "Can not detect how to start Apache!" >&2
  exit 1
fi

sleep 5

output=`mktemp`

if curl -v http://localhost/icingaweb2/authentication/login -o "$output"; then
  if grep -q '<div id="login"' "$output"; then
    echo "Login page available"
    exit 0
  else
    echo "Didn't get a logon page from the webserver!"
    echo
    echo "Output of the page is:"
    echo "====================================="
    cat "$output"
    exit 1
  fi
else
  echo "Request for login page failed!"
  echo
  echo "Output of the page is:"
  echo "====================================="
  cat "$output"
  exit 1
fi
