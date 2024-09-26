#!/bin/sh
while :
do
  if test -f /tmp/fetch-crl-done; then
    echo "Starting Xrootd Process"
    xrootd -c /etc/xrootd/xrootd-clustered.cfg -l /var/log/xrootd/clustered/xrootd.log -R xrootd
    exCode=$?
    echo "XRootD Process quited. Exit code: $exCode"
    exit exCode
  else
    echo "Xrootd start delayed 5seconds. Fetch CRL has not finished..."
    sleep 5
  fi
done
