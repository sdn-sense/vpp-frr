echo 4096 | sudo tee /proc/sys/vm/nr_hugepages
echo 24 | sudo tee /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages


# Make sure core dumps saved inside /tmp (faced segfaults in VPP)
echo '/tmp/core.%e.%p' | sudo tee /proc/sys/kernel/core_pattern

# 2M hugepages
HUGE_DIR="/mnt/huge"

if mount | grep -q "$HUGE_DIR type hugetlbfs"; then
    echo "hugetlbfs is already mounted on $HUGE_DIR."
else
    echo "hugetlbfs not mounted on $HUGE_DIR. Setting it up..."

    sudo mkdir -p "$HUGE_DIR"
    sudo mount -t hugetlbfs -o pagesize=2M none "$HUGE_DIR"

    if [ $? -eq 0 ]; then
        echo "hugetlbfs mounted on $HUGE_DIR with 2MB page size."
    else
        echo "Failed to mount hugetlbfs on $HUGE_DIR."
        exit 1
    fi
fi

# 1 GB hugepages
HUGE_DIR="/mnt/huge_1GB"

if mount | grep -q "$HUGE_DIR type hugetlbfs"; then
    echo "hugetlbfs is already mounted on $HUGE_DIR."
else
    echo "hugetlbfs not mounted on $HUGE_DIR. Setting it up..."

    sudo mkdir -p "$HUGE_DIR"
    sudo mount -t hugetlbfs -o pagesize=1G none "$HUGE_DIR"

    if [ $? -eq 0 ]; then
        echo "hugetlbfs mounted on $HUGE_DIR with 1GB page size."
    else
        echo "Failed to mount hugetlbfs on $HUGE_DIR."
        exit 1
    fi
fi

docker build --network host -t vpp .
docker compose up -d
