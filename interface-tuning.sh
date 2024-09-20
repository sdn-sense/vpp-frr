INTF=$1
echo "Setting MTU size to 9000, txqueuelen to 10000 for $INTF"
echo  "Changing MTU for interface: $INTF ";
ip link set dev $INTF mtu 9000
echo  "Changing txqueuelen for interface: $INTF ";
ip link set dev $INTF txqueuelen 10000

echo "Changing dynamic control  to off for interface: $INTF ";
ethtool -C $INTF adaptive-rx off
echo "Setting interrupt coalescing";
ethtool -C $INTF rx-usecs 1000
echo  "Tune up receive (TX) and transmit (RX) buffers for interface: $INTF ";
MAX_RX=$(ethtool -g $INTF | grep 'RX:' | awk '{print $2}' | head -1)
MAX_TX=$(ethtool -g $INTF | grep 'TX:' | awk '{print $2}' | head -1)
echo  "Receive max (TX) $MAX_TX and transmit max (RX) $MAX_RX for interface: $INTF ";
ethtool -G $INTF rx $MAX_RX tx $MAX_TX
echo "Done changing parameters"
