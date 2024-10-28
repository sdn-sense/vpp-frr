One node:
```
Building configuration...

Current configuration:
!
frr version 8.4_git
frr defaults traditional
hostname vpp-node-0
service integrated-vtysh-config
!
router bgp 65001
 bgp router-id 192.168.101.1
 neighbor 192.168.101.2 remote-as 65002
 !
 address-family ipv4 unicast
  network 192.168.0.0/24
  neighbor 192.168.101.2 soft-reconfiguration inbound
  neighbor 192.168.101.2 route-map IMPORT_POLICY in
  neighbor 192.168.101.2 route-map EXPORT_POLICY out
 exit-address-family
exit
!
ip prefix-list ALLOWED_PREFIXES seq 5 permit 192.168.1.0/24
ip prefix-list ADVERTISED_PREFIXES seq 5 permit 192.168.0.0/24
!
route-map IMPORT_POLICY permit 10
 match ip address prefix-list ALLOWED_PREFIXES
exit
!
route-map EXPORT_POLICY permit 10
 match ip address prefix-list ADVERTISED_PREFIXES
exit
!
end
```

Other end:
```
Building configuration...

Current configuration:
!
frr version 8.4_git
frr defaults traditional
hostname vpp-node-1
service integrated-vtysh-config
!
router bgp 65002
 bgp router-id 192.168.101.2
 neighbor 192.168.101.1 remote-as 65001
 !
 address-family ipv4 unicast
  network 192.168.1.0/24
  neighbor 192.168.101.1 soft-reconfiguration inbound
  neighbor 192.168.101.1 route-map IMPORT_POLICY in
  neighbor 192.168.101.1 route-map EXPORT_POLICY out
 exit-address-family
exit
!
ip prefix-list ALLOWED_PREFIXES seq 5 permit 192.168.0.0/24
ip prefix-list ADVERTISED_PREFIXES seq 5 permit 192.168.1.0/24
!
route-map IMPORT_POLICY permit 10
 match ip address prefix-list ALLOWED_PREFIXES
exit
!
route-map EXPORT_POLICY permit 10
 match ip address prefix-list ADVERTISED_PREFIXES
exit
!
end
```
