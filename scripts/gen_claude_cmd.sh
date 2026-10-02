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

AWS_ACCESS_KEY_ID=$AK \\
AWS_SECRET_ACCESS_KEY=$SK \\
AWS_SESSION_TOKEN=$ST \\
AWS_REGION=us-west-2 \\
CLAUDE_CODE_USE_BEDROCK=1 \\
ANTHROPIC_DEFAULT_SONNET_MODEL=global.anthropic.claude-sonnet-4-6 \\
ANTHROPIC_DEFAULT_OPUS_MODEL=global.anthropic.claude-opus-4-6-v1 \\
ANTHROPIC_DEFAULT_HAIKU_MODEL=global.anthropic.claude-haiku-4-5-20251001-v1:0 \\
claude
EOF
