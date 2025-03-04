1. What if we want to take IPv6 addresses from Fabric and use it on Kubernetes slice - expanding Fabric slice to NRP resources and use same IPs.
2. Go to SENSE-O and ask for BGP Peering between Fabric Slice and NRP SDSC. Use FABRIC-SDSC-BGP-Peering and describe that we use public range from SDSC and same public range from CERN Fabric. 
3. Submit to SENSE-O; While waiting for it - look at xrootd containers running in osg-gil namespace - inside container take IP, and show that it is public. Try to do ping6 and tracepath6 from xrootd container while it is in creating:
    ping6 and tracepath6 should fail and not reach out VPP FRR; Ping will not work, but tracepath will show it reaches - it mainly fails because there is different paths;
4. Once SENSE path is created - ping6 and traceroute6 should work - as SENSE added all the requires routes on the Routers and redirect traffic as needed.
5. For CERN Net-attach - find out vlan for previous request - and update it inside net-attach-def. apply it. Now this net-attach definition is using IP Ranges from Fabric. 
6. Apply net-attach def; show pods, and apply pods; wait for sense request to be ready;
7. Ping and traceroute from SDSC
[root@origin-114-400-65ff647749-9kv4g /]# tracepath6 2602:fcfb:001d:fff2::1
 1?: [LOCALHOST]                        0.013ms pmtu 9000
 1:  _gateway                                              0.454ms
 1:  _gateway                                              0.264ms
 2:  2602:fcfb:1d:fff2::1                                159.247ms reached
     Resume: pmtu 9000 hops 2 back 2
---
[root@origin-114-400-65ff647749-9kv4g /]# ping6 2602:fcfb:001d:fff2::1
PING 2602:fcfb:001d:fff2::1(2602:fcfb:1d:fff2::1) 56 data bytes
64 bytes from 2602:fcfb:1d:fff2::1: icmp_seq=1 ttl=63 time=159 ms
64 bytes from 2602:fcfb:1d:fff2::1: icmp_seq=2 ttl=63 time=159 ms
^C
--- 2602:fcfb:001d:fff2::1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 158.992/159.009/159.026/0.017 ms
---
7. Once ready - ping from container will not work to VPP instance. This is because on Fabric our fff2 range belongs to vlan 101. This part is still manual and SENSE does not change public IPs and VLANs at the sites - but that is one of the discussions we are having and might support it in the near future. 
So go to VPP container and execute (need to find out which vlan was used for previous request 942):

set interface state Ethernet1/0/0.101 down
set interface ip address del Ethernet1/0/0.101 2602:fcfb:1d:fff2::1/64

set interface ip address Ethernet2/0/0.###REPLACEME### 2602:fcfb:1d:fff2::1/64

8. Ping should work, traceroute go via fabric router;
9 Run FDT on public



nohup java -jar fdt.jar 11111
nohup java -jar fdt.jar 11112
nohup java -jar fdt.jar 11113
set interface ip address del Ethernet2/0/0.803 2602:fcfb:1d:fff1::1/64
set interface ip address del Ethernet3/0/0.863 2602:fcfb:1d:fff2::1/64
set interface ip address del Ethernet4/0/0.928 2602:fcfb:1d:fff3::1/64


set interface ip address Ethernet3/0/0.863 2602:fcfb:1d:fff1::1/64

set interface ip address Ethernet4/0/0.928 2602:fcfb:1d:fff3::1/64

set interface ip address Ethernet2/0/0.803 2602:fcfb:1d:fff2::1/64
