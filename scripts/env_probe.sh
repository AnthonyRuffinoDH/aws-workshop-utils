#!/usr/bin/env bash
set -euo pipefail

echo "=================================================="
echo " ENVIRONMENT & AWS CAPABILITY PROBE"
echo "=================================================="

echo ""
echo "[System]"
echo "  Arch:     $(uname -m)"
echo "  Kernel:   $(uname -r)"
echo "  Hostname: $(hostname)"

echo ""
echo "[Tools]"
for tool in git gh aws ssh-keygen curl jq python3 node docker; do
    if command -v "$tool" &>/dev/null; then
        echo "  $tool: $(command -v "$tool")"
    else
        echo "  $tool: NOT FOUND"
    fi
done

echo ""
echo "[AWS Identity]"
if CALLER_ID=$(aws sts get-caller-identity 2>/dev/null); then
    echo "  Account: $(echo "$CALLER_ID" | jq -r '.Account')"
    echo "  ARN:     $(echo "$CALLER_ID" | jq -r '.Arn')"
    REGION=$(aws configure get region 2>/dev/null || echo "${AWS_REGION:-${AWS_DEFAULT_REGION:-us-west-2}}")
    echo "  Region:  $REGION"
else
    echo "  ERROR: sts get-caller-identity failed"
fi

echo ""
echo "[EC2 Metadata]"
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 60" --max-time 3 2>/dev/null || true)
if [ -n "$TOKEN" ]; then
    PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
        http://169.254.169.254/latest/meta-data/public-ipv4 --max-time 3 2>/dev/null || echo "none")
    INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
        http://169.254.169.254/latest/meta-data/instance-id --max-time 3 2>/dev/null || echo "unknown")
    SG_IDS=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
        http://169.254.169.254/latest/meta-data/security-groups --max-time 3 2>/dev/null || echo "unknown")
    echo "  Instance:  $INSTANCE_ID"
    echo "  Public IP: $PUBLIC_IP"
    echo "  Sec Groups: $SG_IDS"
else
    echo "  Metadata service unreachable"
fi

echo ""
echo "[AWS Service Access]"

# S3
echo -n "  S3: "
if aws s3 ls --max-items 1 &>/dev/null; then
    BUCKET_COUNT=$(aws s3 ls 2>/dev/null | wc -l)
    echo "OK ($BUCKET_COUNT buckets visible)"
else
    echo "DENIED or ERROR"
fi

# Lambda
echo -n "  Lambda: "
if FUNCS=$(aws lambda list-functions --query 'Functions[].FunctionName' --output text 2>/dev/null); then
    FUNC_COUNT=$(echo "$FUNCS" | wc -w)
    echo "OK ($FUNC_COUNT functions)"
    echo "    $FUNCS" | tr '\t' '\n' | sed 's/^/    /'
else
    echo "DENIED or ERROR"
fi

# Bedrock - invoke test
echo -n "  Bedrock (invoke): "
INVOKE_RESULT=$(aws bedrock-runtime invoke-model \
    --model-id anthropic.claude-haiku-1-20250219 \
    --content-type application/json \
    --body '{"anthropic_version":"bedrock-2023-05-31","max_tokens":10,"messages":[{"role":"user","content":"say hi"}]}' \
    /dev/stdout 2>/dev/null | head -c 200 || echo "FAILED")
if echo "$INVOKE_RESULT" | grep -q "content"; then
    echo "OK (claude-haiku responded)"
else
    echo "DENIED or ERROR"
fi

# Bedrock AgentCore
echo -n "  AgentCore CLI: "
if command -v aws &>/dev/null && aws bedrock-agentcore help &>/dev/null; then
    echo "INSTALLED"
else
    echo "NOT AVAILABLE"
fi

# DynamoDB
echo -n "  DynamoDB: "
if aws dynamodb list-tables --max-items 1 &>/dev/null; then
    echo "OK"
else
    echo "DENIED or ERROR"
fi

# IAM (read-only check)
echo -n "  IAM (read): "
if aws iam get-user &>/dev/null; then
    echo "OK"
else
    echo "DENIED (expected for assumed role)"
fi

# SSM
echo -n "  SSM: "
if aws ssm describe-instance-information --max-results 1 &>/dev/null; then
    echo "OK"
else
    echo "DENIED or ERROR"
fi

echo ""
echo "=================================================="
echo " PROBE COMPLETE"
echo "=================================================="
