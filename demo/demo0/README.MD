1. Deploy FRR (Software Router without VPP)
2. Once deployed - SiteRM Frontend will not be able to access it. For now we add default routes and tell it to use pub-0. Usually siteRM Frontend is deployed closest to the site router (ssh -i /opt/siterm/config/ssh-keys/frrsshkey ubuntu@2602:fcfb:1d:fff0::2)
3. From host2 show ip -6 r and following line: 2602:fcfb:1d:fff1::/64 via 2602:fcfb:1d:fff2::1 dev enp10s0 metric 1024 pref medium
   Which is manual enforcement to route traffic via fff2 for fff1 range

ubuntu@host2:~$ ping6 2602:fcfb:1d:fff1::1 -c 5
PING 2602:fcfb:1d:fff1::1 (2602:fcfb:1d:fff1::1): 56 data bytes
64 bytes from cern-sub1-gw1.exp.fabric-testbed.net: icmp_seq=0 ttl=64 time=0.285 ms
64 bytes from cern-sub1-gw1.exp.fabric-testbed.net: icmp_seq=1 ttl=64 time=0.246 ms
64 bytes from cern-sub1-gw1.exp.fabric-testbed.net: icmp_seq=2 ttl=64 time=0.291 ms
64 bytes from cern-sub1-gw1.exp.fabric-testbed.net: icmp_seq=3 ttl=64 time=0.267 ms
64 bytes from cern-sub1-gw1.exp.fabric-testbed.net: icmp_seq=4 ttl=64 time=0.316 ms
--- 2602:fcfb:1d:fff1::1 ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.246/0.281/0.316/0.024 ms
ubuntu@host2:~$ ping6 2602:fcfb:1d:fff1::2 -c 5
PING 2602:fcfb:1d:fff1::2 (2602:fcfb:1d:fff1::2): 56 data bytes
64 bytes from cern-sub1-host1.exp.fabric-testbed.net: icmp_seq=0 ttl=63 time=1.410 ms
64 bytes from cern-sub1-host1.exp.fabric-testbed.net: icmp_seq=1 ttl=63 time=1.325 ms
64 bytes from cern-sub1-host1.exp.fabric-testbed.net: icmp_seq=2 ttl=63 time=1.341 ms
64 bytes from cern-sub1-host1.exp.fabric-testbed.net: icmp_seq=3 ttl=63 time=1.333 ms
64 bytes from cern-sub1-host1.exp.fabric-testbed.net: icmp_seq=4 ttl=63 time=1.306 ms
--- 2602:fcfb:1d:fff1::2 ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max/stddev = 1.306/1.343/1.410/0.035 ms

4. Move to demo 1 - deploy vpp + frr
