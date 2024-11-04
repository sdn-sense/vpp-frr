#!/bin/bash
INTF=$1
PREFIX=$2
ENV_FILE="env"

PCI_DEV=$(sudo lshw -c network -businfo | grep "$INTF" | awk '{print $1}' | awk -F'@' '{print $2}')

INTF_VAR="ENV_${PREFIX}_INTF"
PCI_VAR="ENV_${PREFIX}_INTF_PCI"

# Check if the interface variable exists and compare its value
if grep -q "^${INTF_VAR}=" "$ENV_FILE"; then
    CURRENT_INTF=$(grep "^${INTF_VAR}=" "$ENV_FILE" | cut -d'=' -f2)
    if [ "$CURRENT_INTF" != "$INTF" ]; then
        sed -i "s/^${INTF_VAR}=.*/${INTF_VAR}=\"$INTF\"/" "$ENV_FILE"
    fi
else
    echo "${INTF_VAR}=\"$INTF\"" >> "$ENV_FILE"
fi

# Check if the PCI variable exists and compare its value
if grep -q "^${PCI_VAR}=" "$ENV_FILE"; then
    CURRENT_PCI=$(grep "^${PCI_VAR}=" "$ENV_FILE" | cut -d'=' -f2)
    if [ "$CURRENT_PCI" != "$PCI_DEV" ]; then
        sed -i "s/^${PCI_VAR}=.*/${PCI_VAR}=\"$PCI_DEV\"/" "$ENV_FILE"
    fi
else
    echo "${PCI_VAR}=\"$PCI_DEV\"" >> "$ENV_FILE"
fi
