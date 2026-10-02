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
# AWS Workshop Credentials (expires: $EXP)
# Paste these into a local terminal:

export AWS_ACCESS_KEY_ID=$AK
export AWS_SECRET_ACCESS_KEY=$SK
export AWS_SESSION_TOKEN=$ST
export AWS_REGION=us-west-2
export CLAUDE_CODE_USE_BEDROCK=1
export ANTHROPIC_DEFAULT_SONNET_MODEL=global.anthropic.claude-sonnet-4-6
export ANTHROPIC_DEFAULT_OPUS_MODEL=global.anthropic.claude-opus-4-6-v1
export ANTHROPIC_DEFAULT_HAIKU_MODEL=global.anthropic.claude-haiku-4-5-20251001-v1:0
EOF
