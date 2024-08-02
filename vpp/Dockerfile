FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg \
                iproute2 \
                iputils-ping

WORKDIR /vpp
RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
RUN apt-get update && apt-get install -y vpp vpp-plugin-core vpp-plugin-dpdk python3-vpp-api vpp-dbg vpp-dev
RUN mkdir -p /var/log/vpp
