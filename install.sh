#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$ROOT/period-space" || ! -f "$ROOT/keyd.conf" ]]; then
  echo "run this from the period-space repo: cd ~/github/period-space && ./install.sh" >&2
  exit 1
fi

if ! command -v keyd >/dev/null 2>&1; then
  if command -v dnf >/dev/null 2>&1; then
    echo "installing keyd with dnf"
    sudo dnf copr enable -y alternateved/keyd
    sudo dnf install -y keyd
  elif command -v pacman >/dev/null 2>&1; then
    echo "installing keyd with pacman"
    sudo pacman -S --needed --noconfirm keyd
  else
    echo "keyd is not installed. Install it first:" >&2
    echo "  https://github.com/rvaiya/keyd" >&2
    exit 1
  fi
fi

python3 "$ROOT/period-space" install --enable
python3 "$ROOT/period-space" status
