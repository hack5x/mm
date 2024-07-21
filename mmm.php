#!/bin/bash


REMOTE_USER="asterisk"
REMOTE_HOST="162.243.110.5"
KEY_PATH="/home/asterisk/.ssh/my_new_key"


ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -N ""


if [ ! -f "${KEY_PATH}.pub" ]; then
  echo "Error: Public key file not found!"
  exit 1
fi


ssh-copy-id -i "${KEY_PATH}.pub" "${REMOTE_USER}@${REMOTE_HOST}"


ssh -i "$KEY_PATH" "$REMOTE_USER@$REMOTE_HOST"
