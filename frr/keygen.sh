#!/bin/bash

KEY_NAME=frrsshkey
KEY_PATH="${HOME}/.ssh/${KEY_NAME}"
AUTH_KEYS="${HOME}/.ssh/authorized_keys"

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

# Generate SSH key if it doesn't exist
if [ ! -f "${KEY_PATH}" ]; then
  ssh-keygen -t rsa -b 4096 -f "${KEY_PATH}" -N ""
  echo "SSH key generated at ${KEY_PATH}"
else
  echo "SSH key already exists at ${KEY_PATH}"
fi

# Add public key to authorized_keys if not already present
if [ -f "${KEY_PATH}.pub" ]; then
  PUB_KEY=$(cat "${KEY_PATH}.pub")
  
  if ! grep -q "${PUB_KEY}" "${AUTH_KEYS}" 2>/dev/null; then
    echo "${PUB_KEY}" >> "${AUTH_KEYS}"
    chmod 600 "${AUTH_KEYS}"
    echo "Public key added to ${AUTH_KEYS}"
  else
    echo "Public key already exists in ${AUTH_KEYS}"
  fi
else
  echo "Public key not found at ${KEY_PATH}.pub"
fi
