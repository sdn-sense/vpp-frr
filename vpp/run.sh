#!/usr/bin/env bash

set -eux

# disable all interface
for iface in $(ip l | awk -F ":" '/^[0-9]+:/{dev=$2 ; if ( dev !~ /^ lo|docker0|enp3s0$/) {print $2}}')
do
  ip link set down dev $iface
done

exec /usr/bin/vpp -c /etc/vpp/startup.conf
