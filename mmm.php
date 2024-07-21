#!/bin/bash


REMOTE_USER="asterisk"
REMOTE_HOST="162.243.110.5"
KEY_PATH="$HOME/.ssh/my_new_key"


ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -N ""


ssh-copy-id -i "${KEY_PATH}.pub" "${REMOTE_USER}@${REMOTE_HOST}"


ssh -i "$KEY_PATH" "$REMOTE_USER@$REMOTE_HOST"
