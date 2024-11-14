#!/usr/bin/env python3
"""
This script sends UDP packets to a specified IPv6 address and port, measures the round-trip time (RTT) for each packet,
and calculates statistics every 1000 packets, including the average, standard deviation, and minimum RTT.

Usage:
    python3 udp-sender.py <port>

Arguments:
    <port> (int): The UDP port number to connect to.

Socket Configuration:
    - Binds to an ephemeral port on the host and sends packets to a target address ("2602:fcfb:1d:fff1::2") with the
      specified port.

Packet Transmission:
    - Sends a UDP packet (32 bytes of zeroed data) and immediately waits for a response.
    - Measures the RTT in microseconds between sending and receiving the packet.
    - Records RTTs in a list for statistical analysis.

Statistics Output:
    - Every 1000 packets, computes and prints the following:
        * Packets per second (pps)
        * Average RTT (avg_rtt) in microseconds
        * Standard deviation of RTT (dev_rtt) in microseconds
        * Minimum RTT (min_rtt) in microseconds
    - Resets the RTT list after each output to start fresh for the next set of 1000 packets.

Requirements:
    - Python 3.x
"""
import sys
import time
import socket
import statistics

if len(sys.argv) != 2:
    print("Usage: python3 udp-sender.py <port>")
    sys.exit(1)

fd = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
fd.bind(("::", int(1000 + int(sys.argv[1]))))
fd.connect(("2602:fcfb:1d:fff1::2", int(sys.argv[1])))

rtts = []
pps = 0
start_time = time.time()

while True:
    t1 = time.time()
    fd.sendmsg([b"\x00" * 32])
    fd.recvmsg(32)
    t2 = time.time()
    rtt = (t2 - t1) * 1000000
    rtts.append(rtt)
    pps += 1
    if pps % 1000 == 0:
        avg_rtt = statistics.mean(rtts)
        dev_rtt = statistics.stdev(rtts) if len(rtts) > 1 else 0
        min_rtt = min(rtts)
        print(f"pps= {pps} avg= {avg_rtt:.3f}us dev= {dev_rtt:.3f}us min={min_rtt:.3f}us")
        rtts = []
