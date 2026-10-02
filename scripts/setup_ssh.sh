#!/usr/bin/env bash
set -euo pipefail

echo "=================================================="
echo " SSH KEY SETUP"
echo "=================================================="

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$SSH_KEY" ]; then
    echo "[+] Generating new ed25519 SSH key..."
    ssh-keygen -t ed25519 -C "workshop-session@aws" -f "$SSH_KEY" -N ""
else
    echo "[+] SSH key already exists at $SSH_KEY"
fi

# Ensure GitHub is in known_hosts
if ! grep -q "github.com" "$SSH_DIR/known_hosts" 2>/dev/null; then
    echo "[+] Adding github.com to known_hosts..."
    ssh-keyscan github.com >> "$SSH_DIR/known_hosts" 2>/dev/null
fi

echo ""
echo "---- COPY THIS PUBLIC KEY TO https://github.com/settings/keys ----"
cat "${SSH_KEY}.pub"
echo "-------------------------------------------------------------------"
echo ""
