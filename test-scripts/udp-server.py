#!/usr/bin/env python3
"""
UDP Echo Server Script

This script implements a simple UDP echo server that listens on an IPv6 address and specified port.
It receives UDP packets from clients and sends back (echoes) the received data to the client.

Usage:
    python udp-server.py <port>

Arguments:
    <port> (int): The UDP port number on which the server will listen for incoming packets.

Socket Configuration:
    - Creates a UDP socket with IPv6 addressing.
    - Binds the socket to the unspecified IPv6 address ("::") and listens on the specified port
      for incoming connections.

Echo Functionality:
    - Receives up to 32 bytes of data from a client.
    - Sends back the received data to the client's address, effectively echoing the message.

Loop Behavior:
    - Continuously waits for incoming messages in an infinite loop.
    - Each received message is immediately echoed back to the sender.

Requirements:
    - Python 3.x
"""
import sys
import socket

if len(sys.argv) != 2:
    print("Usage: python udp_echo_server.py <port>")
    sys.exit(1)

fd = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
fd.bind(("::", int(sys.argv[1])))
while True:
    data, ancdata, flags, client_addr = fd.recvmsg(32)
    fd.sendmsg([data], [], 0, client_addr)
