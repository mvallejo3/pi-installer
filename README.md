# Pi Installer

An automated installer script for [Pi](https://pi.dev) that ensures all prerequisites (Node.js >= 22.19.0 and npm) are installed before setting up Pi.

## Quick Install (One Command)

Run the installer directly from your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/mvallejo3/pi-installer/main/install-pi.sh | bash
```

Or using `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/mvallejo3/pi-installer/main/install-pi.sh | bash
```

## What It Does

1. **Checks Node.js & npm**: Verifies if Node.js (>= 22.19.0) and npm are installed and meet the minimum version requirement.
2. **Installs NVM (if needed)**: If Node.js is missing or outdated, installs [NVM](https://github.com/nvm-sh/nvm) (v0.41.0) and loads it into the current session.
3. **Installs Node.js (if needed)**: Installs the required Node.js version via NVM.
4. **Installs Pi**: Runs the official Pi installer (`curl -fsSL https://pi.dev/install.sh | sh`).
5. **Verifies Installation**: Checks that `pi` is reachable in your PATH and provides instructions if PATH adjustment is needed.

## Manual / Local Installation

You can also clone the repository and run the script locally:

```bash
git clone https://github.com/mvallejo3/pi-installer.git
cd pi-installer
chmod +x install-pi.sh
./install-pi.sh
```

## Post-Install

Once installation finishes, restart your terminal or reload your shell profile. If the `pi` command is not immediately recognized, ensure `~/.local/bin` is in your `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Verify your installation:

```bash
pi --version
```
