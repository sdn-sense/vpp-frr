
docker compose exec vpp vppctl set int ip address $1 $2
docker compose exec vpp vppctl set interface state $1 up
docker compose exec vpp vppctl show interface address
#docker compose exec vpp vppctl set int ip address HGigEther8/0/0 192.168.0.1/24
#docker compose exec vpp vppctl set interface state HGigEther8/0/0 up
