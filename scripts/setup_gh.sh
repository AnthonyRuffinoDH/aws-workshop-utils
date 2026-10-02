#!/usr/bin/env bash
set -euo pipefail

echo "=================================================="
echo " GITHUB CLI (gh) STATUS"
echo "=================================================="

if ! command -v gh &>/dev/null; then
    echo "[!] 'gh' is not installed."
    echo "    On AL2023: sudo yum install -y gh"
    exit 1
fi

echo "[+] gh is installed: $(gh --version | head -1)"

if gh auth status &>/dev/null; then
    echo "[+] gh is authenticated:"
    gh auth status
else
    echo "[!] gh is NOT authenticated."
    echo ""
    echo "To log in with a token:"
    echo "  echo 'ghp_YOUR_TOKEN' | gh auth login --with-token"
    echo ""
    echo "Or interactively:"
    echo "  gh auth login"
fi

echo ""
