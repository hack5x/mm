
#!/usr/bin/env bash
set -euo pipefail

# Installer script: installs build deps and masscan-ng on many distros
# Usage: chmod +x setup_masscan_env.sh && ./setup_masscan_env.sh

# Helper prints
info()  { printf "\e[1;34m[INFO]\e[0m %s\n" "$*"; }
warn()  { printf "\e[1;33m[WARN]\e[0m %s\n" "$*"; }
error() { printf "\e[1;31m[ERROR]\e[0m %s\n" "$*" >&2; exit 1; }

# Detect distro (ID and ID_LIKE from /etc/os-release)
detect_pkg_mgr() {
  if   command -v apt-get >/dev/null 2>&1; then echo "apt"; return
  elif command -v dnf >/dev/null 2>&1; then echo "dnf"; return
  elif command -v yum >/dev/null 2>&1; then echo "yum"; return
  elif command -v pacman >/dev/null 2>&1; then echo "pacman"; return
  elif command -v apk >/dev/null 2>&1; then echo "apk"; return
  else echo "unknown"; return
  fi
}

PKG_MGR=$(detect_pkg_mgr)
info "Detected package manager: $PKG_MGR"

# Common package sets mapped by pkg manager
install_with_apt() {
  sudo apt-get update
  sudo apt-get install -y git build-essential make gcc \
    libpcre3-dev libssl-dev libpcap-dev \
    coreutils procps grep gawk sed iptables
}

install_with_dnf() {
  sudo dnf -y install git make gcc pcre-devel openssl-devel libpcap-devel \
    procps-ng gawk sed iptables
}

install_with_yum() {
  sudo yum -y install git make gcc pcre-devel openssl-devel libpcap-devel \
    procps gawk sed iptables
}

install_with_pacman() {
  sudo pacman -Sy --noconfirm
  sudo pacman -S --noconfirm git base-devel pcre openssl libpcap procps-ng gawk sed iptables
}

install_with_apk() {
  sudo apk update
  sudo apk add --no-cache git build-base pcre-dev openssl-dev libpcap-dev \
    procps gawk sed iptables
}

case "$PKG_MGR" in
  apt)   info "Installing packages via apt"; install_with_apt ;;
  dnf)   info "Installing packages via dnf"; install_with_dnf ;;
  yum)   info "Installing packages via yum"; install_with_yum ;;
  pacman)info "Installing packages via pacman"; install_with_pacman ;;
  apk)   info "Installing packages via apk"; install_with_apk ;;
  *)     error "Unsupported or unknown package manager. Install dependencies manually." ;;
esac

# Verify essential commands exist
REQUIRED_CMDS=(git make gcc sed awk grep ps shuf split)
for c in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$c" >/dev/null 2>&1; then
    warn "Required command not found: $c  (install it via your package manager)"
  fi
done

# Build & install masscan-ng from bi-zone repo (if not present)
MC_DIR="$HOME/masscan-ng"
if command -v masscan-ng >/dev/null 2>&1; then
  info "masscan-ng already installed: $(command -v masscan-ng)"
else
  if [ -d "$MC_DIR" ]; then
    info "masscan-ng source already cloned at $MC_DIR — pulling latest"
    (cd "$MC_DIR" && git pull --ff-only || true)
  else
    info "Cloning masscan-ng into $MC_DIR"
    git clone https://github.com/bi-zone/masscan-ng "$MC_DIR"
  fi

  info "Building masscan-ng (this may take a moment)..."
  (cd "$MC_DIR" && make)

  info "Installing masscan-ng (requires sudo)"
  sudo bash -c "cd '$MC_DIR' && make install"
fi

# Final checks
info "Final checks:"
if command -v masscan-ng >/dev/null 2>&1; then
  info "masscan-ng installed at: $(command -v masscan-ng)"
  masscan-ng --help | head -n 10 || true
else
  warn "masscan-ng not found after build. Check build logs in $MC_DIR"
fi

info "Done. Verify 'iptables' and other commands are available and configure 'port' and targets file before running your scanning script."
