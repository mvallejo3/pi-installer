#!/usr/bin/env bash
set -euo pipefail

# Pi requires Node.js >= 22.19.0 and npm
MIN_NODE_MAJOR=22
MIN_NODE_MINOR=19
NVM_VERSION="v0.41.0"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# --- Helper functions ---

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# Check if Node exists and meets the minimum version requirement
is_node_adequate() {
  if ! has_cmd node || ! has_cmd npm; then
    return 1
  fi

  node -e "
    const [maj, min] = process.versions.node.split('.').map(Number);
    process.exit(maj > ${MIN_NODE_MAJOR} || (maj === ${MIN_NODE_MAJOR} && min >= ${MIN_NODE_MINOR}) ? 0 : 1);
  " 2>/dev/null
}

load_nvm() {
  # NVM is a shell function, so we must source nvm.sh
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck disable=SC1090
    \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    return 0
  fi
  return 1
}

# --- Step 1: Check Node.js and npm ---

echo "==> Checking Node.js and npm requirements..."

# First, attempt to load NVM if it's already installed on disk but not loaded
if ! is_node_adequate && [ -s "$NVM_DIR/nvm.sh" ]; then
  echo "    Found existing NVM at $NVM_DIR, loading it..."
  load_nvm || true
fi

if is_node_adequate; then
  echo "    Node $(node -v) and npm $(npm -v) already satisfy requirements."
  echo "    Skipping NVM and Node.js installation."
else
  if has_cmd node; then
    echo "    Node $(node -v) found, but Pi requires Node >= ${MIN_NODE_MAJOR}.${MIN_NODE_MINOR}.0."
  else
    echo "    Node.js is not installed."
  fi

  # --- Step 2: Ensure NVM is installed ---
  if load_nvm; then
    echo "    NVM is already installed at $NVM_DIR."
  else
    echo "==> Installing NVM (${NVM_VERSION})..."
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
    load_nvm || {
      echo "Error: Failed to load NVM after installation." >&2
      exit 1
    }
  fi

  # --- Step 3: Install Node via NVM ---
  echo "==> Installing Node.js (LTS)..."
  nvm install --lts
  nvm use --lts

  # Fallback if LTS happens to be older than the required version
  if ! is_node_adequate; then
    echo "    LTS did not meet >= ${MIN_NODE_MAJOR}.${MIN_NODE_MINOR}.0. Installing current Node..."
    nvm install node
    nvm use node
  fi
fi

# --- Step 4: Verify Node & npm ---
echo "==> Verifying Node runtime:"
echo "    node: $(command -v node) ($(node -v))"
echo "    npm:  $(command -v npm) (v$(npm -v))"

# --- Step 5: Install Pi ---
echo "==> Installing Pi..."
curl -fsSL https://pi.dev/install.sh | sh

# --- Step 6: Post-install verification ---
# Check if pi is directly reachable or in standard local bin paths
if ! has_cmd pi && [ -x "$HOME/.local/bin/pi" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if has_cmd pi; then
  echo "==> Pi installation successful! Version: $(pi --version 2>/dev/null || echo 'installed')"
else
  echo ""
  echo "Notice: Pi was installed, but you may need to reload your shell or add"
  echo "its directory to PATH. Run:"
  echo '  export PATH="$HOME/.local/bin:$PATH"'
fi

echo ""
echo "All set!"
