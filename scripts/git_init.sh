#!/usr/bin/env bash
set -euo pipefail

echo "=================================================="
echo " GIT & GITHUB FULL SETUP"
echo "=================================================="

# 1. Git identity
echo ""
echo "[Step 1] Git Identity"
CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -n "$CURRENT_NAME" ]; then
    echo "  Current name: $CURRENT_NAME"
    read -rp "  Keep this name? [Y/n]: " KEEP_NAME
    if [[ "$KEEP_NAME" =~ ^[Nn] ]]; then
        read -rp "  Enter name: " GIT_NAME
        git config --global user.name "$GIT_NAME"
    fi
else
    read -rp "  Enter your Git name: " GIT_NAME
    git config --global user.name "$GIT_NAME"
fi

if [ -n "$CURRENT_EMAIL" ]; then
    echo "  Current email: $CURRENT_EMAIL"
    read -rp "  Keep this email? [Y/n]: " KEEP_EMAIL
    if [[ "$KEEP_EMAIL" =~ ^[Nn] ]]; then
        read -rp "  Enter email: " GIT_EMAIL
        git config --global user.email "$GIT_EMAIL"
    fi
else
    read -rp "  Enter your Git email: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
fi

echo "  [+] Git identity: $(git config --global user.name) <$(git config --global user.email)>"

# 2. GitHub token
echo ""
echo "[Step 2] GitHub Token"
echo "  We'll use one token for both 'gh' and 'git'."
echo "  Paste a GitHub PAT (classic or fine-grained) with repo scope."
echo ""
read -rsp "  Token (hidden): " GH_TOKEN_INPUT
echo ""

if [ -z "$GH_TOKEN_INPUT" ]; then
    echo "  [!] No token provided. Skipping GitHub setup."
    exit 1
fi

export GH_TOKEN="$GH_TOKEN_INPUT"

# 3. Auth gh
echo ""
echo "[Step 3] Authenticating gh CLI..."
if gh auth status &>/dev/null; then
    echo "  [+] gh is already authenticated."
else
    echo "  [+] Logging in via token..."
    echo "$GH_TOKEN" | gh auth login --with-token 2>&1
fi

# 4. Configure git to use gh as credential helper
echo ""
echo "[Step 4] Configuring git credential helper via gh..."
gh auth setup-git 2>&1
echo "  [+] git will now use 'gh' for HTTPS credentials."

# 5. Clean up old plaintext credentials
echo ""
echo "[Step 5] Cleaning up old credentials..."
if [ -f "$HOME/.git-credentials" ]; then
    rm -f "$HOME/.git-credentials"
    echo "  [+] Removed ~/.git-credentials (plaintext tokens)"
else
    echo "  [+] No ~/.git-credentials found (already clean)"
fi

# Remove the old store helper if set
if git config --global credential.helper 2>/dev/null | grep -q "store"; then
    git config --global --unset credential.helper
    echo "  [+] Removed 'store' credential helper from git config"
fi

# 6. Persist GH_TOKEN for this session
echo ""
echo "[Step 6] Persisting GH_TOKEN for shell session..."
SHELL_RC="$HOME/.bashrc"
if ! grep -q "export GH_TOKEN=" "$SHELL_RC" 2>/dev/null; then
    echo "export GH_TOKEN=\"$GH_TOKEN\"" >> "$SHELL_RC"
    echo "  [+] Added GH_TOKEN to $SHELL_RC"
else
    sed -i "s|^export GH_TOKEN=.*|export GH_TOKEN=\"$GH_TOKEN\"|" "$SHELL_RC"
    echo "  [+] Updated GH_TOKEN in $SHELL_RC"
fi

# 7. SSH key (generate if missing)
echo ""
echo "[Step 7] SSH Key"
SSH_KEY="$HOME/.ssh/id_ed25519"
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

if [ ! -f "$SSH_KEY" ]; then
    echo "  [+] Generating ed25519 SSH key..."
    ssh-keygen -t ed25519 -C "workshop-session@aws" -f "$SSH_KEY" -N ""
else
    echo "  [+] SSH key already exists."
fi

if ! grep -q "github.com" "$HOME/.ssh/known_hosts" 2>/dev/null; then
    ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
fi

echo ""
echo "  Public key (add to https://github.com/settings/keys if using SSH):"
cat "${SSH_KEY}.pub"

# 8. Verify
echo ""
echo "[Step 8] Verification"
echo -n "  gh auth: "
gh auth status 2>&1 | grep -o "Logged in to.*" || echo "FAILED"
echo -n "  git credential helper: "
git config --global credential.helper 2>/dev/null || echo "not set (gh manages it)"

echo ""
echo "=================================================="
echo " GIT SETUP COMPLETE"
echo "=================================================="
echo ""
echo " Run 'source ~/.bashrc' or open a new terminal for GH_TOKEN to take effect."
echo ""
