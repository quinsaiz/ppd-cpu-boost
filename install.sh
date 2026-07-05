#!/bin/bash

# ── Constants ─────────────────────────────────────────────────────────────────

readonly INSTALL_DIR="/usr/bin"
readonly SYSTEMD_DIR="/usr/lib/systemd/system"
readonly SERVICE_NAME="ppd-cpu-boost.service"
readonly SCRIPT_NAME="ppd-cpu-boost"
readonly PACKAGE_NAME="ppd-cpu-boost"
readonly PACKAGE_VERSION="1.1.0"

FILES_TO_ARCHIVE=("$SCRIPT_NAME" "$SERVICE_NAME")

# ── Colors ────────────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' NC=''
fi

info() { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ── Create Archive ────────────────────────────────────────────────────────────

create_arch_archive() {
  local archive_name="${PACKAGE_NAME}-${PACKAGE_VERSION}.tar.gz"
  local temp_dir="${PACKAGE_NAME}-${PACKAGE_VERSION}"

  info "Creating archive for PKGBUILD"

  for file in "${FILES_TO_ARCHIVE[@]}"; do
    if [ ! -f "$file" ]; then
      error "Required file $file not found. Please ensure all files are in the root directory."
      return 1
    fi
  done

  rm -rf "$temp_dir"
  mkdir -p "$temp_dir"

  info "Copying files to $temp_dir..."
  cp -f "${FILES_TO_ARCHIVE[@]}" "$temp_dir/"

  info "Creating archive $archive_name..."
  tar -czf "$archive_name" "$temp_dir"

  rm -rf "$temp_dir"

  info "Archive successfully created: $archive_name"
  return 0
}

# ── Check Dependencies ────────────────────────────────────────────────────────

check_dependencies() {
  local missing=0

  info "Checking dependencies..."

  if ! command -v systemctl >/dev/null 2>&1; then
    error "systemd is not installed (systemctl not found)"
    missing=1
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    error "python3 is not installed"
    missing=1
  elif ! python3 -c "import gi" >/dev/null 2>&1; then
    error "python3-gobject (gi) is not installed"
    missing=1
  fi

  if ! systemctl list-unit-files | grep -q power-profiles-daemon; then
    error "power-profiles-daemon is not installed"
    missing=1
  fi

  if [ "$missing" -ne 0 ]; then
    echo
    warn "Please install missing dependencies and try again."
    exit 1
  fi

  info "All dependencies are satisfied."
}

# ── Main ──────────────────────────────────────────────────────────────────────

case "$1" in
-u | --uninstall)
  if [ "$(id -u)" -ne 0 ]; then
    error "This script must be run with root privileges. Use sudo."
    exit 1
  fi

  info "Stopping and removing the service..."

  systemctl stop "$SERVICE_NAME" 2>/dev/null
  systemctl disable "$SERVICE_NAME" 2>/dev/null

  rm -f "$INSTALL_DIR/$SCRIPT_NAME"
  rm -f "$SYSTEMD_DIR/$SERVICE_NAME"

  systemctl daemon-reload

  info "Removal completed."
  ;;

-b | --build)
  create_arch_archive
  ;;

"" | -i | --install)
  if [ "$(id -u)" -ne 0 ]; then
    error "This script must be run with root privileges. Use sudo."
    exit 1
  fi

  check_dependencies

  info "Performing manual installation..."

  info "Copying $SCRIPT_NAME to $INSTALL_DIR..."
  cp -f "$SCRIPT_NAME" "$INSTALL_DIR/"

  info "Copying $SERVICE_NAME to $SYSTEMD_DIR..."
  cp -f "$SERVICE_NAME" "$SYSTEMD_DIR/"

  chmod 755 "$INSTALL_DIR/$SCRIPT_NAME"
  chmod 644 "$SYSTEMD_DIR/$SERVICE_NAME"

  info "Activating and starting the systemd service..."
  systemctl daemon-reload
  systemctl enable --now "$SERVICE_NAME"

  info "Installation completed."
  ;;

*)
  error "Unknown option: $1"
  echo "Usage: $0 [-i|--install] [-u|--uninstall] [-b|--build]"
  exit 1
  ;;
esac

exit 0
