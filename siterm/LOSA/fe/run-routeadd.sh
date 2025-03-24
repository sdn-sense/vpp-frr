#!/usr/bin/env bash
sleep 30
while true; do
    ip -6 route add 2602:fcfb::/36 via 2602:fcfb:001d:fff0::1 dev e2.99
    ip -6 route add 2001:1458::/32 via 2602:fcfb:001d:fff0::1 dev e2.99
    ip -6 route add 2620:6a::/48 via 2602:fcfb:001d:fff0::1 dev e2.99
    ip -6 route add 2605:d9c0::/32 via 2602:fcfb:001d:fff0::1 dev e2.99
    ip -6 route add 2600:900::/28 via 2602:fcfb:001d:fff0::1 dev e2.99
    ip -6 route add 2001:48d0::/32 via 2602:fcfb:001d:fff0::1 dev e2.99
    ip -6 route add 2620:f:a:50::/64 via 2602:fcfb:001d:fff0::1 dev e2.99
    ip -6 route add 2600:2701:5000:5001::/64 via 2602:fcfb:001d:fff0::1 dev e2.99
    ip -6 route add 2601:0249:187f:cf74::/64 via 2602:fcfb:001d:fff0::1 dev e2.99
    ip -6 route add 2607:f720::/32 via 2602:fcfb:001d:fff0::1 dev e2.99
    sleep 60
done
