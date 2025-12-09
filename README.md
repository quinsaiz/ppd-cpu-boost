# Power Profiles Daemon CPU Boost Sync

The systemd service, which automatically synchronizes CPU Turbo Boost settings with the active power profile set `power-profiles-daemon`.

This provides instant and energy-efficient switching between modes.

## How it works

The script automatically detects the CPU architecture and uses the appropriate control file and logic.

| CPU | Control File | Logic |
| :--- | :--- | :--- |
| **AMD** (cpufreq) | `/sys/devices/system/cpu/cpufreq/boost` | `1` = Boost ON
| **Intel** (intel_pstate) | `/sys/devices/system/cpu/intel_pstate/no_turbo` | `0` = Turbo ON

### Profile Logic

| PPD Profile (`powerprofilesctl`) | Action | Effect |
| :--- | :--- | :--- |
| `performance` | Enable Boost/Turbo | Maximum CPU performance. |
| `balanced` or `power-saver` | Disable Boost/Turbo | Reduced heat and power consumption. |

## Requirements
- python
- python-gobject
- power-profiles-daemon

## Installation

### I. Arch Linux / AUR (Recommended)

Once packaged, users can install via an AUR helper (e.g., `yay` or `paru`).

1. **Clone the PKGBUILD repository:**
   ```bash
   git clone https://aur.archlinux.org/ppd-cpu-boost.git

   cd ppd-cpu-boost
   ```

2. Build and Install (using makepkg -si to clean up source files):
    ```bash
    makepkg -si
    ```

The service is automatically enabled after installation via the pacman hook

### II. Manual Installation

1. **Use the provided `install.sh` script for manual setup.**
    Clone the repository:
    ```bash
    git clone https://github.com/quinsaiz/ppd-cpu-boost.git

    cd ppd-cpu-boost
    ```

2. **Install (requires root privileges):**
    ```bash
    sudo ./install.sh
    ```

## Uninstallation

| Method | Command |
| :--- | :--- |
| Pacman | `sudo pacman -R ppd-cpu-boost`
| Manual | `sudo ./install.sh --uninstall` or `sudo ./install.sh -u`

## Usage and Diagnostics

Check Service Status:
```bash
systemctl status ppd-cpu-boost
```

View Logs (Real-time):
```bash
sudo journalctl -u ppd-cpu-boost -f
```

Verify the Effect (e.g., on AMD systems):
```bash
watch -n1 cat /sys/devices/system/cpu/cpufreq/boost
```