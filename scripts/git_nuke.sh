#!/usr/bin/env bash
set -euo pipefail

echo "=================================================="
echo " NUKING ALL GIT/GITHUB CREDENTIALS"
echo "=================================================="

# gh auth logout
echo "[1] Logging out of gh..."
gh auth logout --hostname github.com 2>/dev/null && echo "  [+] gh logged out" || echo "  [+] gh was not logged in"

# Remove gh config
echo "[2] Removing gh config dir..."
rm -rf "$HOME/.config/gh" && echo "  [+] Removed ~/.config/gh" || true

# Remove git-credentials
echo "[3] Removing ~/.git-credentials..."
rm -f "$HOME/.git-credentials" && echo "  [+] Done" || true

# Remove GH_TOKEN from bashrc
echo "[4] Removing GH_TOKEN from .bashrc..."
sed -i '/^export GH_TOKEN=/d' "$HOME/.bashrc" && echo "  [+] Done" || true
sed -i '/^export GITHUB_TOKEN=/d' "$HOME/.bashrc" && echo "  [+] Done" || true

# Unset env vars in current shell (won't persist but shows intent)
echo "[5] Unsetting env vars (for subshells)..."
unset GH_TOKEN 2>/dev/null || true
unset GITHUB_TOKEN 2>/dev/null || true
echo "  [+] Done (run 'source ~/.bashrc' or new terminal to take effect)"

# Reset git credential helper
echo "[6] Resetting git credential helper..."
git config --global --unset credential.helper 2>/dev/null && echo "  [+] Removed credential.helper" || echo "  [+] No credential.helper was set"
git config --global --unset-all "credential.https://github.com.helper" 2>/dev/null || true

# Reset git identity to defaults
echo "[7] Resetting git identity..."
git config --global user.name "Workshop User"
git config --global user.email "workshop@workshop.com"
echo "  [+] Reset to Workshop User <workshop@workshop.com>"

echo ""
echo "=================================================="
echo " ALL GIT/GITHUB DATA REMOVED"
echo "=================================================="
echo ""
echo " IMPORTANT: Run 'source ~/.bashrc' or open a new terminal,"
echo " then run 'make git-init' to set up fresh."
echo ""
