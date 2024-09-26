#!/bin/sh
while :
do
  if test -f /tmp/fetch-crl-done; then
    echo "Starting cmsd Process"
    cmsd -c /etc/xrootd/xrootd-clustered.cfg -l /var/log/xrootd/clustered/cmsd.log
    exCode=$?
    echo "cmsd Process quited. Exit code: $exCode"
    exit exCode
  else
    echo "cmsD start delayed 5seconds. Fetch CRL has not finished..."
    sleep 5
  fi
done
