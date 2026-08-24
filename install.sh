#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$ROOT/period-space" || ! -f "$ROOT/keyd.conf" ]]; then
  echo "run this from a period-space checkout, or: python3 period-space install" >&2
  exit 1
fi

python3 "$ROOT/period-space" install

echo
if ! command -v keyd >/dev/null 2>&1; then
  echo "keyd is not installed yet. Install it, then run: period-space on"
  echo "  Fedora:  sudo dnf copr enable alternateved/keyd && sudo dnf install keyd"
  echo "  Arch:    sudo pacman -S keyd"
  echo "  others:  https://github.com/rvaiya/keyd"
else
  echo "run: period-space on"
fi
