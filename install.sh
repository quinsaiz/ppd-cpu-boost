#!/bin/bash

INSTALL_DIR="/usr/bin"
SYSTEMD_DIR="/usr/lib/systemd/system"
SERVICE_NAME="ppd-cpu-boost.service"
SCRIPT_NAME="ppd-cpu-boost"
PACKAGE_NAME="ppd-cpu-boost"
PACKAGE_VERSION="1.0.0"

FILES_TO_ARCHIVE=("$SCRIPT_NAME" "$SERVICE_NAME")

if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run with root privileges. Use sudo."
   
   exit 1
fi

create_arch_archive() {
    local archive_name="${PACKAGE_NAME}-${PACKAGE_VERSION}.tar.gz"
    local temp_dir="${PACKAGE_NAME}-${PACKAGE_VERSION}"
    
    echo "Creating archive for PKGBUILD"
    
    for file in "${FILES_TO_ARCHIVE[@]}"; do
        if [ ! -f "$file" ]; then
            echo "ERROR: Required file $file not found. Please ensure all files are in the root directory."
            return 1
        fi
    done

    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"

    echo "Copying files to $temp_dir..."
    cp -f "${FILES_TO_ARCHIVE[@]}" "$temp_dir/"
    
    echo "Creating archive $archive_name..."
    tar -czf "$archive_name" "$temp_dir"

    rm -rf "$temp_dir"

    echo "Archive successfully created: $archive_name"
    return 0
}

case "$1" in
    -u|--uninstall)
        echo "Stopping and removing the service..."

        systemctl stop "$SERVICE_NAME" 2>/dev/null
        systemctl disable "$SERVICE_NAME" 2>/dev/null

        rm -f "$INSTALL_DIR/$SCRIPT_NAME"
        rm -f "$SYSTEMD_DIR/$SERVICE_NAME"

        systemctl daemon-reload

        echo "Removal completed."
        ;;

    -b|--build)
        create_arch_archive
        ;;


    *)
        echo "Performing manual installation..."

        echo "Copying $SCRIPT_NAME to $INSTALL_DIR..."
        cp -f "$SCRIPT_NAME" "$INSTALL_DIR/"
        
        echo "Copying $SERVICE_NAME to $SYSTEMD_DIR..."
        cp -f "$SERVICE_NAME" "$SYSTEMD_DIR/"

        chmod 755 "$INSTALL_DIR/$SCRIPT_NAME"
        chmod 644 "$SYSTEMD_DIR/$SERVICE_NAME"

        echo "Activating and starting the systemd service..."
        systemctl daemon-reload
        systemctl enable --now "$SERVICE_NAME"

        echo "Installation completed."
        ;;
esac

exit 0