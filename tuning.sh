#!/bin/bash


echo "Setting sysctl params"
grep -q '^net.core.rmem_max' /etc/sysctl.conf && sed -i 's/^net.core.rmem_max.*/net.core.rmem_max=2147483647/' /etc/sysctl.conf || echo 'net.core.rmem_max=2147483647' >> /etc/sysctl.conf
grep -q '^net.core.wmem_max' /etc/sysctl.conf && sed -i 's/^net.core.wmem_max.*/net.core.wmem_max=2147483647/' /etc/sysctl.conf || echo 'net.core.wmem_max=2147483647' >> /etc/sysctl.conf
grep -q '^net.ipv4.tcp_rmem' /etc/sysctl.conf && sed -i 's/^net.ipv4.tcp_rmem.*/net.ipv4.tcp_rmem=4096 87380 268435456/' /etc/sysctl.conf || echo 'net.ipv4.tcp_rmem=4096 87380 2147483647' >> /etc/sysctl.conf
grep -q '^net.ipv4.tcp_wmem' /etc/sysctl.conf && sed -i 's/^net.ipv4.tcp_wmem.*/net.ipv4.tcp_wmem=4096 87380 268435456/' /etc/sysctl.conf || echo 'net.ipv4.tcp_wmem=4096 87380 2147483647' >> /etc/sysctl.conf
grep -q '^net.core.netdev_max_backlog' /etc/sysctl.conf && sed -i 's/^net.core.netdev_max_backlog.*/net.core.netdev_max_backlog=250000/' /etc/sysctl.conf || echo 'net.core.netdev_max_backlog=250000' >> /etc/sysctl.conf
grep -q '^net.ipv4.tcp_no_metrics_save' /etc/sysctl.conf && sed -i 's/^net.ipv4.tcp_no_metrics_save.*/net.ipv4.tcp_no_metrics_save=1/' /etc/sysctl.conf || echo 'net.ipv4.tcp_no_metrics_save=1' >> /etc/sysctl.conf
grep -q '^net.ipv4.tcp_adv_win_scale' /etc/sysctl.conf && sed -i 's/^net.ipv4.tcp_adv_win_scale.*/net.ipv4.tcp_adv_win_scale=1/' /etc/sysctl.conf || echo 'net.ipv4.tcp_adv_win_scale=1' >> /etc/sysctl.conf
grep -q '^net.ipv4.tcp_low_latency' /etc/sysctl.conf && sed -i 's/^net.ipv4.tcp_low_latency.*/net.ipv4.tcp_low_latency=1/' /etc/sysctl.conf || echo 'net.ipv4.tcp_low_latency=1' >> /etc/sysctl.conf
grep -q '^net.ipv4.tcp_timestamps' /etc/sysctl.conf && sed -i 's/^net.ipv4.tcp_timestamps.*/net.ipv4.tcp_timeip addressstamps=0/' /etc/sysctl.conf || echo 'net.ipv4.tcp_timestamps=0' >> /etc/sysctl.conf
grep -q '^net.ipv4.tcp_sack' /etc/sysctl.conf && sed -i 's/^net.ipv4.tcp_sack.*/net.ipv4.tcp_sack=1/' /etc/sysctl.conf || echo 'net.ipv4.tcp_sack=1' >> /etc/sysctl.conf
grep -q '^net.ipv4.tcp_moderate_rcvbuf ' /etc/sysctl.conf && sed -i 's/^net.ipv4.tcp_moderate_rcvbuf .*/net.ipv4.tcp_moderate_rcvbuf=1/' /etc/sysctl.conf || echo 'net.ipv4.tcp_moderate_rcvbuf=1' >> /etc/sysctl.conf
grep -q '^net.ipv4.tcp_congestion_control' /etc/sysctl.conf && sed -i 's/^net.ipv4.tcp_congestion_control.*/net.ipv4.tcp_congestion_control=bbr/' /etc/sysctl.conf || echo 'net.ipv4.tcp_congestion_control=bbr' >> /etc/sysctl.conf
grep -q '^net.ipv4.tcp_mtu_probing' /etc/sysctl.conf && sed -i 's/^net.ipv4.tcp_mtu_probing.*/net.ipv4.tcp_mtu_probing=1/' /etc/sysctl.conf || echo 'net.ipv4.tcp_mtu_probing=1' >> /etc/sysctl.conf
grep -q '^net.core.default_qdisc' /etc/sysctl.conf && sed -i 's/^net.core.default_qdisc.*/net.core.default_qdisc=fq/' /etc/sysctl.conf || echo 'net.core.default_qdisc=fq' >> /etc/sysctl.conf

echo "Restarting sysctl"
sysctl -p /etc/sysctl.conf
