# Raspberry Pi Setup Guide

This guide covers how to set up and run Discord-OTP-Forcer on a **Raspberry Pi** running **Raspberry Pi OS** (Bookworm or later, Debian-based).

---

## Prerequisites

| Requirement | Detail |
|---|---|
| **Hardware** | Raspberry Pi 3B+, 4, 5 or newer (1 GB+ RAM; 2 GB+ recommended) |
| **OS** | Raspberry Pi OS Bookworm (64-bit recommended) or later |
| **Python** | 3.11+ (ships with Bookworm) |
| **Network** | Internet connection required |

> **Tip:** A 64-bit (arm64/aarch64) OS image is recommended for better Python package compatibility. The 32-bit (armhf) image also works but may have slower performance.

---

## Quick Start (Automated)

```bash
# 1. Clone the repository
git clone https://github.com/Derpitron/Discord-OTP-Forcer.git
cd Discord-OTP-Forcer

# 2. Make the setup script executable and run it
chmod +x scripts/RaspberryPi/setup.sh
./scripts/RaspberryPi/setup.sh

# 3. Edit configuration
nano config/program.yml
nano config/account.yml

# 4. Run the program
chmod +x scripts/RaspberryPi/start.sh
./scripts/RaspberryPi/start.sh
```

That's it! The setup script handles everything: system packages, Python venv, and pip dependencies.

---

## Manual Setup (Step by Step)

### 1. Install System Packages

```bash
sudo apt-get update

# On Bookworm:
sudo apt-get install -y \
    python3 python3-pip python3-venv \
    chromium-browser chromium-chromedriver \
    libatk1.0-0 libatk-bridge2.0-0 libcups2 \
    libxkbcommon0 libgbm1 libpango-1.0-0 libcairo2 \
    libasound2 libnspr4 libnss3 xdg-utils

# On Trixie (Debian 13 / testing) — package names differ:
sudo apt-get install -y \
    python3 python3-pip python3-venv \
    chromium chromium-driver \
    libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 \
    libxkbcommon0 libgbm1 libpango-1.0-0 libcairo2 \
    libasound2t64 libnspr4 libnss3 xdg-utils
```

**Why these packages?**
- `chromium-browser` / `chromium-chromedriver` — Chromium is the native ARM-compatible browser. Google Chrome does not provide official ARM builds.
- `libatk*`, `libcups2`, `libgbm1`, etc. — Shared libraries required by Chromium to run, even in headless mode.
- `python3-venv` — Needed because Raspberry Pi OS enforces PEP 668 (externally managed Python), so a venv is mandatory for pip installs.

### 2. Create a Virtual Environment

```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 3. Install Python Dependencies

```bash
pip install -r dependencies.txt
```

All dependencies in `dependencies.txt` are pure-Python or ship ARM wheels:
- `seleniumbase` — browser automation framework
- `PyYAML` — config parsing
- `loguru` — logging
- `stackprinter` — enhanced tracebacks
- `regex-string-generator` — code generation

### 4. Configure the Program

```bash
nano config/program.yml
nano config/account.yml
```

**Recommended `program.yml` settings for Raspberry Pi:**

```yaml
# Use Chromium — the ARM-native browser on Pi
browser: Chromium

# Set to True if running without a monitor/display
headless: True

# Increase tolerance for slower ARM CPU
elementLoadTolerance: 5

# Slightly higher delays to reduce CPU/memory pressure
usualAttemptDelayMin: 7
usualAttemptDelayMax: 10
```

### 5. Run the Program

```bash
python3 main.py
```

---

## Differences from Windows Setup

| Aspect | Windows | Raspberry Pi |
|---|---|---|
| **Shell scripts** | `.cmd` files in `scripts/Windows/` | `.sh` files in `scripts/RaspberryPi/` |
| **Browser** | Chrome (x86/x64) | Chromium (ARM native via apt) |
| **ChromeDriver** | Auto-downloaded by SeleniumBase | Installed via `chromium-chromedriver` apt package |
| **Python install** | Manual from python.org | `sudo apt install python3` |
| **Dependency install** | Global pip | `python3 -m venv` + pip (PEP 668 required) |
| **Config editor** | Notepad (opened by setup.cmd) | `nano` / any terminal editor |
| **Line endings** | CRLF | LF (auto-handled by the project) |
| **Low-memory flags** | Not needed | Auto-applied when ARM detected |

---

## How ARM Optimization Works

The program **automatically detects** ARM architecture at runtime and applies these Chromium flags:

| Flag | Purpose |
|---|---|
| `--disable-dev-shm-usage` | Uses `/tmp` instead of `/dev/shm` (often only 64 MB on Pi) |
| `--disable-gpu` | Avoids GPU compositing issues on Pi's VideoCore |
| `--no-zygote` | Disables Chromium's zygote process manager to save ~30 MB RAM |
| `--single-process` | Runs all Chromium threads in one process — less RAM overhead |
| `--disable-software-rasterizer` | Skips CPU-heavy software rendering fallback |

These flags are only applied on ARM — x86/x64 systems are unaffected.

---

## Running Without a Display (Headless)

If your Pi has no monitor (SSH-only, or running as a server):

1. Set `headless: True` in `config/program.yml`
2. Set `logCreation: True` to capture logs to file (no terminal to read from after session ends)
3. **Captcha note:** The program pauses for manual captcha completion. In headless mode, you cannot interact with the captcha. If Discord sends a captcha, you will need to either:
   - Temporarily connect a display/VNC
   - Use `headless: False` with VNC/X11 forwarding

### VNC Option (Headless with Display Access)

```bash
# Install a VNC server
sudo apt-get install -y realvnc-vnc-server
sudo raspi-config   # Enable VNC under Interface Options

# Then connect from another machine with a VNC client
# and run the program with headless: False
```

---

## Troubleshooting

### "chromedriver not found" or version mismatch
```bash
# On Bookworm:
sudo apt-get install -y chromium-chromedriver
# On Trixie:
sudo apt-get install -y chromium-driver

# Verify
chromedriver --version
chromium --version      # Trixie
chromium-browser --version  # Bookworm
```

### SeleniumBase downloads the wrong chromedriver
SeleniumBase may try to download an x86 chromedriver. The system `chromium-chromedriver` package provides the correct ARM binary at `/usr/bin/chromedriver`. If SeleniumBase ignores it, you can set:
```bash
export CHROMEDRIVER_PATH=/usr/bin/chromedriver
```

### Out of memory
- Ensure `headless: True` is set (saves ~200 MB RAM)
- Close other applications
- Consider adding swap:
  ```bash
  sudo dphys-swapfile swapoff
  sudo sed -i 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=1024/' /etc/dphys-swapfile
  sudo dphys-swapfile setup
  sudo dphys-swapfile swapon
  ```

### Python version too old
Raspberry Pi OS Bullseye ships Python 3.9. Upgrade to **Bookworm** (which has 3.11) or install Python 3.11+ from source:
```bash
sudo apt-get install -y build-essential libffi-dev libssl-dev
wget https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tar.xz
tar -xf Python-3.11.9.tar.xz
cd Python-3.11.9
./configure --enable-optimizations
make -j$(nproc)
sudo make altinstall
python3.11 --version
```

### Permission denied on scripts
```bash
chmod +x scripts/RaspberryPi/setup.sh
chmod +x scripts/RaspberryPi/start.sh
chmod +x scripts/Linux/setup.sh
chmod +x scripts/Linux/start.sh
```

---

## Limitations

1. **Captcha completion** requires a visible browser or VNC — it cannot be done in pure headless mode.
2. **Performance** is slower than x86 due to ARM CPU constraints. Expect slightly longer page loads and code submission times. Adjust `elementLoadTolerance` upward if you see timeout errors.
3. **Thorium browser** does not provide official ARM builds. Use `Chromium` on Pi.
4. **Brave browser** is not available on ARM via apt. Use `Chromium` on Pi.
5. **RAM usage** with Chromium: expect ~300–500 MB total. A Pi with 1 GB RAM works but leaves little headroom. 2 GB+ is recommended.
