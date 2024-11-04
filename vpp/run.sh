#!/usr/bin/env bash

CONFIG_TEMPLATE="/etc/vpp/startup.conf-template"
CONFIG_OUTPUT="/etc/vpp/startup.conf"


# Set interfaces down (vpp expects them to be down as dpdk will overtake it)
ip link set down $ENV_PUBLIC_INTF
# Hardware specific Optimizations for public intf
ethtool -K $ENV_PUBLIC_INTF rx off
ethtool -K $ENV_PUBLIC_INTF tx off
ethtool -K $ENV_PUBLIC_INTF sg off
ethtool -K $ENV_PUBLIC_INTF tso off
ethtool -K $ENV_PUBLIC_INTF ufo off
ethtool -K $ENV_PUBLIC_INTF gso off
ethtool -K $ENV_PUBLIC_INTF gro off
ethtool -K $ENV_PUBLIC_INTF lro off
ethtool -K $ENV_PUBLIC_INTF rxvlan off
ethtool -K $ENV_PUBLIC_INTF txvlan off
ethtool -K $ENV_PUBLIC_INTF ntuple off
ethtool -K $ENV_PUBLIC_INTF rxhash off
ethtool --set-eee $ENV_PUBLIC_INTF eee off

# Set private interface down (vpp will start it and expects it to be down)
ip link set down $ENV_PRIVATE_INTF
# Hardware specific Optimizations for public intf
ethtool -K $ENV_PRIVATE_INTF rx off
ethtool -K $ENV_PRIVATE_INTF tx off
ethtool -K $ENV_PRIVATE_INTF sg off
ethtool -K $ENV_PRIVATE_INTF tso off
ethtool -K $ENV_PRIVATE_INTF ufo off
ethtool -K $ENV_PRIVATE_INTF gso off
ethtool -K $ENV_PRIVATE_INTF gro off
ethtool -K $ENV_PRIVATE_INTF lro off
ethtool -K $ENV_PRIVATE_INTF rxvlan off
ethtool -K $ENV_PRIVATE_INTF txvlan off
ethtool -K $ENV_PRIVATE_INTF ntuple off
ethtool -K $ENV_PRIVATE_INTF rxhash off
ethtool --set-eee $ENV_PRIVATE_INTF eee off


# Update configuration file to match correct PCI device inside VPP

cp $CONFIG_TEMPLATE $CONFIG_OUTPUT

# Replace all variables in the configuration file
sed -i "s/ENV_MAIN_CORE/$ENV_MAIN_CORE/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_CORELIST_WORKERS/$ENV_CORELIST_WORKERS/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_BUFFERS_PER_NUMA/$ENV_BUFFERS_PER_NUMA/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_PRIVATE_INTF_RXQ/$ENV_PRIVATE_INTF_RXQ/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_PRIVATE_INTF_TXQ/$ENV_PRIVATE_INTF_TXQ/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_PRIVATE_INTF_RXDESC/$ENV_PRIVATE_INTF_RXDESC/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_PRIVATE_INTF_TXDESC/$ENV_PRIVATE_INTF_TXDESC/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_PUBLIC_INTF_RXQ/$ENV_PUBLIC_INTF_RXQ/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_PUBLIC_INTF_TXQ/$ENV_PUBLIC_INTF_TXQ/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_PUBLIC_INTF_RXDESC/$ENV_PUBLIC_INTF_RXDESC/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_PUBLIC_INTF_TXDESC/$ENV_PUBLIC_INTF_TXDESC/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_PUBLIC_INTF_PCI/$ENV_PUBLIC_INTF_PCI/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_PRIVATE_INTF_PCI/$ENV_PRIVATE_INTF_PCI/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_PUBLIC_INTF/$ENV_PUBLIC_INTF/g" "$CONFIG_OUTPUT"
sed -i "s/ENV_PRIVATE_INTF/$ENV_PRIVATE_INTF/g" "$CONFIG_OUTPUT"

echo "Configuration generated at $CONFIG_OUTPUT"
cat $CONFIG_OUTPUT

echo "Start VPP"
exec /usr/bin/vpp -c /etc/vpp/startup.conf
