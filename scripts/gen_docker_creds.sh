#!/usr/bin/env bash
set -euo pipefail

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
ROLE="workshop-resources-ec2-CodeEditorInstanceRole-yZ85hEw2BNLt"
CREDS=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
    "http://169.254.169.254/latest/meta-data/iam/security-credentials/$ROLE")

AK=$(echo "$CREDS" | jq -r '.AccessKeyId')
SK=$(echo "$CREDS" | jq -r '.SecretAccessKey')
ST=$(echo "$CREDS" | jq -r '.Token')
EXP=$(echo "$CREDS" | jq -r '.Expiration')

cat <<EOF
# Credentials expire: $EXP
# Copy and run this on your local machine:

make claude-docker \\
  AK=$AK \\
  SK=$SK \\
  ST=$ST
EOF
