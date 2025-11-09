
# This script must be run with sudo
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script with sudo."
  exit 1
fi

# Source the configuration file
if [[ -f "config.conf" ]]; then
    source "config.conf"
else
    echo "ERROR: config.conf not found." >&2
    exit 1
fi

# --- Logging Functions ---
SCRIPT_NAME=$(basename "$0")
log_message() { echo "$(date '+%Y-%m-%d %H:%M:%S') [$SCRIPT_NAME] INFO: $1" >> "$LOG_FILE"; }
log_error() { echo "$(date '+%Y-%m-%d %H:%M:%S') [$SCRIPT_NAME] ERROR: $1" >> "$ERROR_LOG"; echo "ERROR: $1" >&2; }
# --- End Logging ---

log_message "System update process started."
echo "Starting system update... (This may take a while)"

# Update package lists
log_message "Running apt update..."
if ! apt-get update -y; then
    log_error "apt-get update failed."
    exit 1
fi

# Upgrade installed packages
log_message "Running apt upgrade..."
if ! apt-get upgrade -y; then
    log_error "apt-get upgrade failed."
    exit 1
fi

# Cleanup: Remove unnecessary packages
log_message "Running apt autoremove..."
if ! apt-get autoremove -y; then
    log_error "apt-get autoremove failed."
fi

# Cleanup: Clear package cache
log_message "Running apt clean..."
if ! apt-get clean; then
    log_error "apt-get clean failed."
fi

log_message "System update and cleanup finished successfully."
echo "System update and cleanup finished successfully."
