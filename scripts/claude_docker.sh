#!/usr/bin/env bash
set -euo pipefail

# Accept creds as env vars (from Make args) or fetch from instance metadata
if [ -n "${AK:-}" ] && [ -n "${SK:-}" ] && [ -n "${ST:-}" ]; then
    echo "[+] Using provided credentials."
else
    echo "[+] Fetching AWS credentials from instance metadata..."
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
        -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
    ROLE="workshop-resources-ec2-CodeEditorInstanceRole-yZ85hEw2BNLt"
    CREDS=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
        "http://169.254.169.254/latest/meta-data/iam/security-credentials/$ROLE")

    AK=$(echo "$CREDS" | jq -r '.AccessKeyId')
    SK=$(echo "$CREDS" | jq -r '.SecretAccessKey')
    ST=$(echo "$CREDS" | jq -r '.Token')
    EXP=$(echo "$CREDS" | jq -r '.Expiration')
    echo "[+] Credentials expire: $EXP"
fi

echo "[+] Building Docker image..."

DOCKER_DIR="$(cd "$(dirname "$0")/.." && pwd)"

docker build -t claude-workshop -f- "$DOCKER_DIR" <<'DOCKERFILE'
FROM node:22-alpine

RUN apk add --no-cache bash curl jq git python3 aws-cli

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

WORKDIR /workspace
CMD ["/bin/bash"]
DOCKERFILE

echo "[+] Launching container..."
echo "[+] Run 'claude' inside to start Claude Code."
echo ""

docker run -it --rm \
    -e AWS_ACCESS_KEY_ID="$AK" \
    -e AWS_SECRET_ACCESS_KEY="$SK" \
    -e AWS_SESSION_TOKEN="$ST" \
    -e AWS_REGION=us-west-2 \
    -e CLAUDE_CODE_USE_BEDROCK=1 \
    -e ANTHROPIC_DEFAULT_SONNET_MODEL=global.anthropic.claude-sonnet-4-6 \
    -e ANTHROPIC_DEFAULT_OPUS_MODEL=global.anthropic.claude-opus-4-6-v1 \
    -e ANTHROPIC_DEFAULT_HAIKU_MODEL=global.anthropic.claude-haiku-4-5-20251001-v1:0 \
    -v "$(pwd):/workspace" \
    claude-workshop
