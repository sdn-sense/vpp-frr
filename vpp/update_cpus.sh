#!/bin/bash
ENV_FILE="env"

TOTAL_CORES=$(nproc)
USABLE_CORES=$((TOTAL_CORES - 2))

if [ "$USABLE_CORES" -lt 2 ]; then
    echo "Error: Not enough cores available (Min 2 are needed)."
    exit 1
fi

CORELIST_VAR="ENV_CORELIST_WORKERS"
PRIVATE_RXQ_VAR="ENV_PRIVATE_INTF_RXQ"
PRIVATE_TXQ_VAR="ENV_PRIVATE_INTF_TXQ"
PUBLIC_RXQ_VAR="ENV_PUBLIC_INTF_RXQ"
PUBLIC_TXQ_VAR="ENV_PUBLIC_INTF_TXQ"

CORELIST="1-$USABLE_CORES"
MAX_CORES=$USABLE_CORES

update_env_var() {
    VAR_NAME=$1
    VAR_VALUE=$2
    if grep -q "^${VAR_NAME}=" "$ENV_FILE"; then
        CURRENT_VALUE=$(grep "^${VAR_NAME}=" "$ENV_FILE" | cut -d'=' -f2)
        if [ "$CURRENT_VALUE" != "$VAR_VALUE" ]; then
            sed -i "s/^${VAR_NAME}=.*/${VAR_NAME}=\"$VAR_VALUE\"/" "$ENV_FILE"
        fi
    else
        echo "${VAR_NAME}=\"$VAR_VALUE\"" >> "$ENV_FILE"
    fi
}

update_env_var "$CORELIST_VAR" "$CORELIST"
update_env_var "$PRIVATE_RXQ_VAR" "$MAX_CORES"
update_env_var "$PRIVATE_TXQ_VAR" "$MAX_CORES"
update_env_var "$PUBLIC_RXQ_VAR" "$MAX_CORES"
update_env_var "$PUBLIC_TXQ_VAR" "$MAX_CORES"
