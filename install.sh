#!/usr/bin/env bash
# Usage: curl -sSL https://raw.githubusercontent.com/harrison007123/querymind3/main/install.sh | bash

set -euo pipefail

REPO="https://github.com/harrison007123/querymind3"
PACKAGE="querymind3"
MIN_PYTHON="3.9"

# ── Colors ────────────────────────────────────────────────────────
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

error() { echo -e "${RED}${BOLD}  ✗ ERROR:${RESET} $*" >&2; exit 1; }
warn()  { echo -e "${YELLOW}${BOLD}  ⚠${RESET} $*"; }

# ── 1. Check Python ───────────────────────────────────────────────
PYTHON_CMD=""
for cmd in python3 python python3.12 python3.11 python3.10 python3.9; do
  if command -v "$cmd" &>/dev/null; then
    version=$("$cmd" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
    major=$(echo "$version" | cut -d. -f1)
    minor=$(echo "$version" | cut -d. -f2)
    if [ "$major" -ge 3 ] && [ "$minor" -ge 9 ]; then
      PYTHON_CMD="$cmd"
      break
    fi
  fi
done

if [ -z "$PYTHON_CMD" ]; then
  error "Python ${MIN_PYTHON}+ is required but not found.\n  Install it from https://www.python.org/downloads/"
fi

# ── 2. Check & Update pip silently ────────────────────────────────
if ! "$PYTHON_CMD" -m pip --version &>/dev/null; then
  "$PYTHON_CMD" -m ensurepip --upgrade >/dev/null 2>&1 || error "Could not bootstrap pip."
fi
"$PYTHON_CMD" -m pip install --upgrade pip --quiet >/dev/null 2>&1

# ── 3. Install QueryMind 3 silently ───────────────────────────────
"$PYTHON_CMD" -m pip install --upgrade "git+${REPO}.git" --quiet >/dev/null 2>&1 \
  || error "Installation failed. Please check your network connection and try again."

# ── 4. Verify Path ────────────────────────────────────────────────
if ! command -v querymind &>/dev/null; then
  USER_BIN="$("$PYTHON_CMD" -m site --user-base)/bin"
  if [ -f "${USER_BIN}/querymind" ]; then
    QM_BIN="${USER_BIN}/querymind"
    warn "querymind is installed at ${USER_BIN} which may not be on your PATH."
    warn "Add the following to your shell profile:"
    echo "    export PATH=\"${USER_BIN}:\$PATH\""
  fi
fi

# ── Done ──────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}  ✓  QueryMind 3 installed successfully!${RESET}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "  Run ${CYAN}${BOLD}querymind${RESET} in your terminal to get started."
echo ""
