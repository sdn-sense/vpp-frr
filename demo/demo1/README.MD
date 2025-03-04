1. Deploy FRR and VPP with DPDK on Slice. Comment that we disable all interfaces and delete them as this is needed for VPP and VPP will create it's own interfaces;
2. Once deploy VPP - show - that is how interfaces are being configured: https://github.com/sdn-sense/vpp-frr/blob/main/siterm/CERN/fe/startup.gate
3. Deploy FRR - which is the same as in FRR Deployment without VPP;
4. Add all routes; 
5.

ubuntu@host2:~$ ping6 2602:fcfb:1d:fff1::1 -c 5
PING 2602:fcfb:1d:fff1::1 (2602:fcfb:1d:fff1::1): 56 data bytes
64 bytes from cern-sub1-gw1.exp.fabric-testbed.net: icmp_seq=0 ttl=64 time=0.169 ms
64 bytes from cern-sub1-gw1.exp.fabric-testbed.net: icmp_seq=1 ttl=64 time=0.201 ms
64 bytes from cern-sub1-gw1.exp.fabric-testbed.net: icmp_seq=2 ttl=64 time=0.189 ms
64 bytes from cern-sub1-gw1.exp.fabric-testbed.net: icmp_seq=3 ttl=64 time=0.180 ms
64 bytes from cern-sub1-gw1.exp.fabric-testbed.net: icmp_seq=4 ttl=64 time=0.368 ms
--- 2602:fcfb:1d:fff1::1 ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.169/0.221/0.368/0.074 ms
ubuntu@host2:~$ ping6 2602:fcfb:1d:fff1::2 -c 5
PING 2602:fcfb:1d:fff1::2 (2602:fcfb:1d:fff1::2): 56 data bytes
64 bytes from cern-sub1-host1.exp.fabric-testbed.net: icmp_seq=0 ttl=63 time=0.314 ms
64 bytes from cern-sub1-host1.exp.fabric-testbed.net: icmp_seq=1 ttl=63 time=0.223 ms
64 bytes from cern-sub1-host1.exp.fabric-testbed.net: icmp_seq=2 ttl=63 time=0.169 ms
64 bytes from cern-sub1-host1.exp.fabric-testbed.net: icmp_seq=3 ttl=63 time=0.180 ms
64 bytes from cern-sub1-host1.exp.fabric-testbed.net: icmp_seq=4 ttl=63 time=0.167 ms
--- 2602:fcfb:1d:fff1::2 ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.167/0.211/0.314/0.056 ms

Move to demo2:

