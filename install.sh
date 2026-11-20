#!/bin/bash

set -u

# ── Constants ─────────────────────────────────────────────────────────────────

readonly INSTALL_DIR="/usr/bin"
readonly SYSTEMD_DIR="/usr/lib/systemd/system"
readonly SERVICE_NAME="ppd-cpu-boost.service"
readonly SCRIPT_NAME="ppd-cpu-boost"
readonly PACKAGE_NAME="ppd-cpu-boost"
readonly PACKAGE_VERSION="2.0"
readonly FILES_TO_ARCHIVE=("$SCRIPT_NAME" "$SERVICE_NAME")

# ── Colors ────────────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  NC=''
fi

info() { printf '%b\n' "${GREEN}[INFO]${NC}  $*"; }
warn() { printf '%b\n' "${YELLOW}[WARN]${NC}  $*"; }
error() { printf '%b\n' "${RED}[ERROR]${NC} $*" >&2; }

# ── Helpers ───────────────────────────────────────────────────────────────────

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    error "This script must be run with root privileges. Use sudo."
    exit 1
  fi
}

require_source_files() {
  local file
  for file in "${FILES_TO_ARCHIVE[@]}"; do
    if [ ! -f "$file" ]; then
      error "Required file '$file' not found in the current directory."
      return 1
    fi
  done
}

# ── Create Archive ────────────────────────────────────────────────────────────

create_arch_archive() {
  local archive_name="${PACKAGE_NAME}-${PACKAGE_VERSION}.tar.gz"
  local temp_dir="${PACKAGE_NAME}-${PACKAGE_VERSION}"

  info "Creating archive for PKGBUILD..."
  require_source_files || return 1

  rm -rf "$temp_dir"
  mkdir -p "$temp_dir"

  info "Copying files to '$temp_dir'..."
  cp -f "${FILES_TO_ARCHIVE[@]}" "$temp_dir/" || {
    rm -rf "$temp_dir"
    return 1
  }

  info "Creating archive '$archive_name'..."
  if ! tar -czf "$archive_name" "$temp_dir"; then
    rm -rf "$temp_dir"
    error "Failed to create archive '$archive_name'."
    return 1
  fi

  rm -rf "$temp_dir"
  info "Archive successfully created: $archive_name"
}

# ── Check Dependencies ────────────────────────────────────────────────────────

check_dependencies() {
  local missing=0

  info "Checking dependencies..."

  if ! command -v systemctl > /dev/null 2>&1; then
    error "systemd is not installed (systemctl not found)."
    missing=1
  elif ! systemctl list-unit-files --no-legend 2> /dev/null | awk '{print $1}' | grep -qx "power-profiles-daemon.service"; then
    error "power-profiles-daemon.service is not installed."
    missing=1
  fi

  if ! command -v python3 > /dev/null 2>&1; then
    error "python3 is not installed."
    missing=1
  elif ! python3 -c "import dbus_fast" > /dev/null 2>&1; then
    error "python-dbus-fast (dbus_fast) is not installed."
    missing=1
  fi

  if [ "$missing" -ne 0 ]; then
    echo
    warn "Please install missing dependencies and try again."
    exit 1
  fi

  info "All dependencies are satisfied."
}

# ── Actions ───────────────────────────────────────────────────────────────────

uninstall_service() {
  require_root
  info "Stopping and removing the service..."

  systemctl stop "$SERVICE_NAME" 2> /dev/null || true
  systemctl disable "$SERVICE_NAME" 2> /dev/null || true

  rm -f "$INSTALL_DIR/$SCRIPT_NAME"
  rm -f "$SYSTEMD_DIR/$SERVICE_NAME"

  systemctl daemon-reload
  info "Removal completed."
}

install_service() {
  require_root
  require_source_files || exit 1
  check_dependencies

  info "Installing '$SCRIPT_NAME' to '$INSTALL_DIR'..."
  install -m 755 "$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME" || exit 1

  info "Installing '$SERVICE_NAME' to '$SYSTEMD_DIR'..."
  install -m 644 "$SERVICE_NAME" "$SYSTEMD_DIR/$SERVICE_NAME" || exit 1

  info "Activating and starting '$SERVICE_NAME'..."
  systemctl daemon-reload
  systemctl enable --now "$SERVICE_NAME"

  info "Installation completed."
}

# ── Main ──────────────────────────────────────────────────────────────────────

case "${1:-}" in
  -u | --uninstall)
    uninstall_service
    ;;
  -b | --build)
    create_arch_archive || exit 1
    ;;
  "" | -i | --install)
    install_service
    ;;
  *)
    error "Unknown option: $1"
    echo "Usage: $0 [-i|--install] [-u|--uninstall] [-b|--build]"
    exit 1
    ;;
esac

exit 0
