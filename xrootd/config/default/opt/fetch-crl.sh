#!/bin/sh
rm -f /tmp/fetch-crl-done
while :
do
  echo "Fetching CRLs..." `date`
  /usr/sbin/fetch-crl -p 5 -T 10
  touch /tmp/fetch-crl-done
  echo "Done Fetching CRLs. Sleeping for 4hrs"
  sleep 14400
  rm -f /tmp/fetch-crl-done
done 
