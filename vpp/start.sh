echo 4096 | sudo tee /proc/sys/vm/nr_hugepages
docker build --network host . -t vpp
docker compose up -d
