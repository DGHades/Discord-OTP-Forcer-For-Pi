import platform
from loguru import logger


def is_arm() -> bool:
    """Check if running on an ARM architecture (e.g. Raspberry Pi)."""
    machine = platform.machine().lower()
    return machine.startswith("arm") or machine == "aarch64"


def build_chromium_args(headless: bool) -> str | None:
    """
    Build a comma-separated string of Chromium flags appropriate for the
    current platform.  Returns None when no extra flags are needed.

    On ARM (Raspberry Pi) the following optimizations are applied:
      --disable-dev-shm-usage   Use /tmp instead of /dev/shm (often too small on Pi)
      --disable-gpu             Avoids GPU-related issues on Pi's VideoCore
      --no-zygote               Reduces memory by disabling the zygote process
      --single-process          Runs Chromium in a single process to save RAM
      --disable-software-rasterizer  Avoids CPU-heavy software rendering
    """
    args: list[str] = []

    if headless:
        args.append("--log-level=1")

    if is_arm():
        logger.debug("ARM architecture detected — applying low-resource Chromium flags")
        args.extend([
            "--disable-dev-shm-usage",
            "--disable-gpu",
            "--no-zygote",
            "--single-process",
            "--disable-software-rasterizer",
        ])

    return ",".join(args) if args else None
