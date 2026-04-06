#!/bin/sh
HTPASSWD_FILE="/etc/rclone/.htpasswd"

# rclone sends {"user":"...","pass":"..."} on stdin
INPUT=$(cat)
USERNAME=$(echo "$INPUT" | jq -r '.user')
PASSWORD=$(echo "$INPUT" | jq -r '.pass')

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
  exit 1
fi

if ! htpasswd -vb "$HTPASSWD_FILE" "$USERNAME" "$PASSWORD" 2>/dev/null; then
  exit 1
fi

echo "{\"type\":\"local\",\"_root\":\"${RCLONE_DOCUMENT_ROOT}/${USERNAME}\"}"
