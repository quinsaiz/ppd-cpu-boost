# PPD CPU Boost Sync

A systemd service that automatically synchronizes CPU Turbo Boost with the active "power-profiles-daemon" profile.

_Not applicable to AMD processors with "amd-pstate = active"._

## How it works

The script detects the CPU architecture and selects the appropriate sysfs control file:

| CPU                  | Control File                                    | Logic           |
|:---------------------|:------------------------------------------------|:----------------|
| AMD (cpufreq)        | `/sys/devices/system/cpu/cpufreq/boost`         | `1` = Boost on  |
| Intel (intel_pstate) | `/sys/devices/system/cpu/intel_pstate/no_turbo` | `0` = Turbo off |

### Profile Logic

| PPD Profile                | Action              | Effect                          |
|:---------------------------|:--------------------|:--------------------------------|
| `performance`              | Enable Boost/Turbo  | Maximum performance             |
| `balanced` / `power-saver` | Disable Boost/Turbo | Less heat and power consumption |

## Requirements

_They are usually preinstalled on most systems._

- python
- python-gobject
- power-profiles-daemon

---

## Installation

### Arch Linux (AUR)

```bash
git clone https://aur.archlinux.org/ppd-cpu-boost.git && \
cd ppd-cpu-boost && \
makepkg -si
```

The service is activated automatically after installation. If you need to enable it manually:

```bash
sudo systemctl enable --now ppd-cpu-boost.service
```

### Manual

```bash
git clone https://github.com/quinsaiz/ppd-cpu-boost.git && \
cd ppd-cpu-boost && \
chmod +x install.sh && \
sudo ./install.sh
```

### Uninstallation

```bash
# AUR
sudo pacman -Rns ppd-cpu-boost

# Manual
sudo ./install.sh --uninstall
```

---

## Diagnostics

```bash
# Service Status
systemctl status ppd-cpu-boost

# Real-time logs
sudo journalctl -u ppd-cpu-boost -f

# Verifying the effect (example for AMD)
watch -n1 cat /sys/devices/system/cpu/cpufreq/boost
```
