#!/bin/bash


REMOTE_USER="asterisk"
REMOTE_HOST="162.243.110.5"
KEY_PATH="/home/asterisk/.ssh/my_new_key"


echo "Creating new SSH key..."
ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -N ""


if [ ! -f "${KEY_PATH}.pub" ]; then
  echo "Error: Public key file not found!"
  exit 1
fi

echo "Public key created at ${KEY_PATH}.pub"


echo "Copying public key to remote server..."
ssh-copy-id -i "${KEY_PATH}.pub" "${REMOTE_USER}@${REMOTE_HOST}"


if [ $? -ne 0 ]; then
  echo "Error: Failed to copy public key to remote server."
  exit 1
fi


echo "Connecting to remote server..."
ssh -i "$KEY_PATH" "$REMOTE_USER@$REMOTE_HOST"
