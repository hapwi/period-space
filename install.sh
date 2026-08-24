#!/usr/bin/env bash
# Install period-space without cloning:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/hapwi/period-space/main/install.sh)"
set -euo pipefail

RAW="${PERIOD_SPACE_RAW:-https://raw.githubusercontent.com/hapwi/period-space/main}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

fetch() {
  local url="$1" dest="$2"
  if need_cmd curl; then
    curl -fsSL "$url" -o "$dest"
  elif need_cmd wget; then
    wget -qO "$dest" "$url"
  else
    echo "need curl or wget to download period-space" >&2
    exit 1
  fi
}

resolve_root() {
  local src="${BASH_SOURCE[0]:-}"
  if [[ -n "$src" && -f "$src" && "$src" != "bash" && "$src" != "-" ]]; then
    local dir
    dir="$(cd "$(dirname "$src")" && pwd)"
    if [[ -f "$dir/period-space" && -f "$dir/keyd.conf" ]]; then
      printf '%s\n' "$dir"
      return
    fi
  fi
  printf '\n'
}

prompt_sudo() {
  echo "period-space needs sudo so keyd can own the keyboard"
  if [[ -r /dev/tty ]]; then
    sudo -v < /dev/tty
  else
    sudo -v
  fi
}

install_keyd() {
  if need_cmd keyd; then
    return
  fi
  if need_cmd dnf; then
    echo "installing keyd with dnf"
    sudo dnf copr enable -y alternateved/keyd
    sudo dnf install -y keyd
  elif need_cmd pacman; then
    echo "installing keyd with pacman"
    sudo pacman -S --needed --noconfirm keyd
  else
    echo "keyd is not installed. Install it first:" >&2
    echo "  https://github.com/rvaiya/keyd" >&2
    exit 1
  fi
}

main() {
  echo "period-space"
  echo "macOS-style double-space → period"
  echo

  if ! need_cmd python3; then
    echo "python3 is required" >&2
    exit 1
  fi
  if ! need_cmd sudo; then
    echo "sudo is required" >&2
    exit 1
  fi

  local root cleanup=""
  root="$(resolve_root)"
  if [[ -z "$root" ]]; then
    root="$(mktemp -d)"
    cleanup="$root"
    trap 'rm -rf "$cleanup"' EXIT
    echo "downloading from GitHub"
    fetch "$RAW/period-space" "$root/period-space"
    fetch "$RAW/keyd.conf" "$root/keyd.conf"
    chmod +x "$root/period-space"
  fi

  prompt_sudo
  install_keyd
  python3 "$root/period-space" install --enable
  python3 "$root/period-space" status
  echo
  echo "later: period-space update"
}

main "$@"
