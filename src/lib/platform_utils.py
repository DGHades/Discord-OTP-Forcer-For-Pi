import platform
import shutil
from pathlib import Path

from loguru import logger


def is_arm() -> bool:
    """Check if running on an ARM architecture (e.g. Raspberry Pi)."""
    machine = platform.machine().lower()
    return machine.startswith("arm") or machine == "aarch64"


def find_system_chromium() -> str | None:
    """
    Locate the system-installed Chromium binary on Linux ARM.

    On Raspberry Pi, SeleniumBase downloads an x86 Chromium that cannot run
    on ARM ("Exec format error"). This function finds the native ARM binary
    installed via apt so we can pass it as binary_location.

    Returns the path string, or None if not found.
    """
    if not is_arm():
        return None

    # Candidate paths — covers Bookworm (chromium-browser) and Trixie (chromium)
    candidates = [
        "/usr/bin/chromium",
        "/usr/bin/chromium-browser",
    ]
    for path in candidates:
        if Path(path).is_file():
            logger.debug(f"Using system Chromium at {path} (ARM)")
            return path

    # Fallback: search PATH
    found = shutil.which("chromium") or shutil.which("chromium-browser")
    if found:
        logger.debug(f"Using system Chromium from PATH: {found} (ARM)")
        return found

    logger.warning(
        "ARM detected but no system Chromium found. "
        "Install it with: sudo apt install chromium  (or chromium-browser)"
    )
    return None


def build_chromium_args(headless: bool) -> str | None:
    """
    Build a comma-separated string of Chromium flags appropriate for the
    current platform.  Returns None when no extra flags are needed.

    On ARM (Raspberry Pi) the following optimizations are applied:
      --no-sandbox              Required on Linux when Chromium's sandbox can't initialize
      --disable-dev-shm-usage   Use /tmp instead of /dev/shm (often too small on Pi)
      --disable-gpu             Avoids GPU-related issues on Pi's VideoCore
    """
    args: list[str] = []

    if headless:
        args.append("--log-level=1")

    if is_arm():
        logger.debug("ARM architecture detected — applying low-resource Chromium flags")
        args.extend([
            "--no-sandbox",
            "--disable-dev-shm-usage",
            "--disable-gpu",
            "--test-type",
            "--disable-extensions",
            "--disable-background-networking",
        ])

    return ",".join(args) if args else None
