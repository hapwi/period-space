#!/usr/bin/env bash
# Install period-space without cloning:
#   curl -fsSL https://hapwi.github.io/install/period-space.sh | bash
set -euo pipefail

RAW="${PERIOD_SPACE_RAW:-https://raw.githubusercontent.com/hapwi/period-space/refs/heads/main}"
KEYD_RELEASES="https://api.github.com/repos/rvaiya/keyd/releases/latest"
CLEANUP=""

remove_cleanup() {
  if [[ -n "${CLEANUP:-}" ]]; then
    rm -rf "$CLEANUP"
    CLEANUP=""
  fi
}

trap remove_cleanup EXIT

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

json_field() {
  python3 -c 'import json,sys; print(json.load(sys.stdin)[sys.argv[1]])' "$1"
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

load_os() {
  ID=""
  ID_LIKE=""
  UBUNTU_CODENAME=""
  VERSION_CODENAME=""
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
  fi
}

os_like() {
  local needle="$1"
  [[ "${ID:-}" == "$needle" || " ${ID_LIKE:-} " == *" $needle "* ]]
}

prompt_sudo() {
  echo "period-space needs sudo so keyd can own the keyboard"
  if [[ -r /dev/tty ]]; then
    sudo -v < /dev/tty
  else
    sudo -v
  fi
}

ensure_python3() {
  if need_cmd python3; then
    return
  fi
  echo "installing python3"
  if need_cmd dnf; then
    sudo dnf install -y python3
  elif need_cmd apt-get; then
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -qq
    sudo apt-get install -y python3
  elif need_cmd pacman; then
    sudo pacman -S --needed --noconfirm python
  elif need_cmd zypper; then
    sudo zypper --non-interactive install python3
  elif need_cmd xbps-install; then
    sudo xbps-install -Sy python3
  elif need_cmd apk; then
    sudo apk add python3
  else
    echo "python3 is required" >&2
    exit 1
  fi
}

install_build_deps() {
  echo "installing compilers to build keyd"
  if need_cmd dnf; then
    sudo dnf install -y gcc make tar gzip kernel-devel
  elif need_cmd apt-get; then
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -qq
    sudo apt-get install -y gcc make tar gzip "linux-headers-$(uname -r)"
  elif need_cmd pacman; then
    sudo pacman -S --needed --noconfirm base-devel linux-headers tar gzip
  elif need_cmd zypper; then
    sudo zypper --non-interactive install gcc make tar gzip kernel-devel
  elif need_cmd xbps-install; then
    sudo xbps-install -Sy gcc make tar gzip linux-headers
  elif need_cmd apk; then
    sudo apk add build-base linux-headers tar gzip
  elif ! need_cmd gcc || ! need_cmd make; then
    echo "need gcc and make to build keyd" >&2
    exit 1
  fi
}

latest_keyd_tag() {
  local tag=""
  tag="$(curl -fsSL -H 'User-Agent: period-space' "$KEYD_RELEASES" \
    | json_field tag_name 2>/dev/null || true)"
  if [[ -z "$tag" ]]; then
    tag="v2.5.0"
  fi
  printf '%s\n' "$tag"
}

install_keyd_from_source() {
  local dir tag src
  dir="$(mktemp -d)"
  tag="$(latest_keyd_tag)"
  src="$dir/keyd-${tag#v}"
  echo "building keyd ${tag} from source"
  install_build_deps
  fetch "https://github.com/rvaiya/keyd/archive/refs/tags/${tag}.tar.gz" "$dir/keyd.tar.gz"
  tar -xzf "$dir/keyd.tar.gz" -C "$dir"
  make -C "$src"
  sudo make -C "$src" install
  rm -rf "$dir"
  hash -r 2>/dev/null || true
}

apt_has_keyd() {
  apt-cache show keyd >/dev/null 2>&1
}

install_keyd_apt() {
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq || return 1
  if apt_has_keyd; then
    echo "installing keyd with apt"
    sudo apt-get install -y keyd || return 1
    return 0
  fi
  if os_like ubuntu; then
    echo "installing keyd from ppa:keyd-team/ppa"
    sudo apt-get install -y software-properties-common ca-certificates || return 1
    sudo add-apt-repository -y ppa:keyd-team/ppa || return 1
    sudo apt-get update -qq || return 1
    sudo apt-get install -y keyd || return 1
    return 0
  fi
  return 1
}

install_keyd_dnf() {
  echo "installing keyd with dnf"
  sudo dnf install -y dnf-plugins-core || true
  sudo dnf copr enable -y alternateved/keyd || return 1
  sudo dnf install -y keyd || return 1
}

install_keyd() {
  if need_cmd keyd; then
    return
  fi

  load_os
  if [[ "${ID:-}" == nixos ]]; then
    echo "NixOS: add services.keyd.enable = true; to configuration.nix, rebuild, then rerun." >&2
    exit 1
  fi

  if need_cmd dnf; then
    if install_keyd_dnf; then
      return
    fi
    echo "dnf could not install keyd, building from source"
  elif need_cmd pacman; then
    echo "installing keyd with pacman"
    if sudo pacman -S --needed --noconfirm keyd && need_cmd keyd; then
      return
    fi
  elif need_cmd zypper; then
    echo "installing keyd with zypper"
    if sudo zypper --non-interactive install keyd && need_cmd keyd; then
      return
    fi
  elif need_cmd apt-get; then
    if install_keyd_apt; then
      return
    fi
    echo "no keyd package in apt, building from source"
  elif need_cmd xbps-install; then
    echo "installing keyd with xbps"
    if sudo xbps-install -Sy keyd && need_cmd keyd; then
      return
    fi
  elif need_cmd apk; then
    echo "installing keyd with apk"
    if sudo apk add keyd && need_cmd keyd; then
      return
    fi
  fi

  if need_cmd keyd; then
    return
  fi
  install_keyd_from_source
  if ! need_cmd keyd && [[ -x /usr/local/bin/keyd ]]; then
    export PATH="/usr/local/bin:${PATH}"
  fi
  if ! need_cmd keyd; then
    echo "keyd is not installed. Install it first:" >&2
    echo "  https://github.com/rvaiya/keyd" >&2
    exit 1
  fi
}

main() {
  echo "period-space"
  echo "macOS-style double-space → period"
  echo

  if ! need_cmd sudo; then
    echo "sudo is required" >&2
    exit 1
  fi
  if ! need_cmd systemctl; then
    echo "period-space needs systemd so it can enable keyd.service" >&2
    exit 1
  fi
  if ! need_cmd curl && ! need_cmd wget; then
    echo "need curl or wget to download period-space" >&2
    exit 1
  fi

  prompt_sudo
  ensure_python3

  local root raw="$RAW"
  root="$(resolve_root)"
  if [[ -z "$root" ]]; then
    root="$(mktemp -d)"
    CLEANUP="$root"
    local sha=""
    sha="$(curl -fsSL -H 'User-Agent: period-space' \
      https://api.github.com/repos/hapwi/period-space/commits/main \
      | json_field sha 2>/dev/null || true)"
    if [[ -n "$sha" && -z "${PERIOD_SPACE_RAW:-}" ]]; then
      raw="https://raw.githubusercontent.com/hapwi/period-space/${sha}"
    fi
    echo "downloading from GitHub"
    fetch "$raw/period-space" "$root/period-space"
    fetch "$raw/keyd.conf" "$root/keyd.conf"
    chmod +x "$root/period-space"
  fi

  install_keyd
  python3 "$root/period-space" install --enable
  python3 "$root/period-space" status
  echo
  echo "later: period-space update"
}

main "$@"
