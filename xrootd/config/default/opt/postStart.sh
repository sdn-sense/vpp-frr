#!/bin/bash
# PostStart script will copy and change ownership of the XRootD certificates and macaroon secret
# as xrootd expects it to be owned by xrootd user.

mkdir -p /etc/grid-security/xrootd/

cp /etc/grid-security/xrootd*.pem /etc/grid-security/xrootd/
chown -R xrootd:xrootd /etc/grid-security/xrootd/

cp /tmp/macaroon-secret /etc/xrootd/macaroon-secret
chown xrootd:xrootd /etc/xrootd/macaroon-secret
