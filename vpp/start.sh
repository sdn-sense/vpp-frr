echo 2048 | sudo tee /proc/sys/vm/nr_hugepages
docker compose -f compose.yaml up -d
