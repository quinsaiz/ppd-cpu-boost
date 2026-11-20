# PPD CPU Boost Sync

A `systemd` daemon that synchronizes AMD CPU boost (`/sys/devices/system/cpu/cpufreq/boost`) with the active `power-profiles-daemon` profile over D-Bus, handling profile changes, daemon restarts, and system resume events.

> **Note:** Designed for AMD processors (`AuthenticAMD`) with `/sys/devices/system/cpu/cpufreq/boost` available.

## How It Works

The daemon connects to the system D-Bus (`org.freedesktop.UPower.PowerProfiles` or `net.hadess.PowerProfiles`), watches `ActiveProfile` property changes and `systemd-logind` `PrepareForSleep` signals, and writes `1` or `0` to `/sys/devices/system/cpu/cpufreq/boost` only when the target value differs from the current one.

### Profile Policy

| PPD Profile | Boost State | `boost` Value | Effect |
| :--- | :--- | :--- | :--- |
| `performance` | Enabled | `1` | Maximum boost clocks |
| `balanced` | Disabled | `0` | Lower heat and power draw |
| `power-saver` | Disabled | `0` | Maximum power savings |

## Requirements

- `python` (Python 3)
- `python-dbus-fast` (`dbus_fast`)
- `power-profiles-daemon`
- `systemd`

## Installation

```bash
git clone https://github.com/quinsaiz/ppd-cpu-boost.git && \
cd ppd-cpu-boost && \
chmod +x install.sh && \
sudo ./install.sh
```

### Uninstallation

```bash

sudo ./install.sh --uninstall
```

## Diagnostics & Configuration

```bash
# Service status
systemctl status ppd-cpu-boost.service

# Live logs
journalctl -u ppd-cpu-boost.service -f

# Current CPU boost value
cat /sys/devices/system/cpu/cpufreq/boost
```

Set `PPD_BOOST_DEBUG=1` in the `systemd` unit or environment to enable verbose debug logs.
