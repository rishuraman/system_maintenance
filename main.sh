
# Set base directory to where the script is located
BASE_DIR=$(dirname "$(readlink -f "$0")")
cd "$BASE_DIR"

# Source the configuration file
if [[ -f "config.conf" ]]; then
    source "config.conf"
else
    echo "CRITICAL: config.conf not found. Exiting." >&2
    exit 1
fi

# --- Setup Logging and Modules ---
MODULE_DIR="modules"
LOG_DIR="logs"

# Create log directory and files if they don't exist
mkdir -p "$LOG_DIR"
touch "$LOG_FILE" "$ERROR_LOG" "$BACKUP_LOG"

# Error Handling : Check if log files are writable
if [[ ! -w "$LOG_FILE" ]] || [[ ! -w "$ERROR_LOG" ]] || [[ ! -w "$BACKUP_LOG" ]]; then
    echo "CRITICAL: Log files in $LOG_DIR are not writable. Check permissions." >&2
    exit 1
fi

# --- Logging Functions ---
SCRIPT_NAME=$(basename "$0")
log_message() { echo "$(date '+%Y-%m-%d %H:%M:%S') [$SCRIPT_NAME] INFO: $1" >> "$LOG_FILE"; }
log_error() { echo "$(date '+%Y-%m-%d %H:%M:%S') [$SCRIPT_NAME] ERROR: $1" >> "$ERROR_LOG"; echo "ERROR: $1" >&2; }
# --- End Logging ---

# --- Menu Functions ---
show_menu() {
    echo "=============================="
    echo "      System Maintenance      "
    echo "=============================="
    echo "1. Run System Backup"
    echo "2. Run System Update & Cleanup"
    echo "3. Monitor Backup Logs"
    echo "4. View Maintenance Log"
    echo "5. View Error Log"
    echo "6. View Backup Log"
    echo "Q. Quit"
    echo "------------------------------"
    read -p "Enter your choice: " choice
}

run_backup() {
    echo "--- Starting Backup Task ---"
    # This no longer pipes output to the main log file
    bash "$MODULE_DIR/backup.sh"
    echo "--- Backup Task Finished ---"
}

run_update() {
    echo "--- Starting Update Task ---"
    echo "This task requires administrator privileges."
    # Error Handling : Correctly call with sudo
    if ! sudo bash "$MODULE_DIR/update.sh"; then
        log_error "Update script failed."
    fi
    echo "--- Update Task Finished ---"
}

run_log_monitor() {
    echo "--- Starting Backup Log Monitoring Task ---"
    bash "$MODULE_DIR/monitor_logs.sh"
    echo "--- Log Monitoring Finished ---"
}

view_log() {
    echo "--- Displaying Maintenance Log (Last 15 Lines) ---"
    tail -n 15 "$LOG_FILE"
    echo "--- End of Log ---"
}

view_error_log() {
    echo "--- Displaying Error Log (Last 15 Lines) ---"
    if [[ -s "$ERROR_LOG" ]]; then
        tail -n 15 "$ERROR_LOG"
    else
        echo "No errors logged. Good job!"
    fi
    echo "--- End of Log ---"
}

view_backup_log() {
    echo "--- Displaying Backup Log (Last 15 Lines) ---"
    if [[ -s "$BACKUP_LOG" ]]; then
        tail -n 15 "$BACKUP_LOG"
    else
        echo "No backups have run yet."
    fi
    echo "--- End of Log ---"
}


# --- Main Loop ---
log_message "Maintenance suite started."
while true; do
    show_menu
    case $choice in
        1)
            run_backup
            ;;
        2)
            run_update
            ;;
        3)
            run_log_monitor
            ;;
        4)
            view_log
            ;;
        5)
            view_error_log
            ;;
        6)
            view_backup_log
            ;;
        [Qq])
            echo "Exiting, Goodbye!..."
            log_message "Maintenance suite stopped."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            log_error "Invalid menu option entered: $choice"
            ;;
    esac
    echo # Add a newline for readability
    read -p "Press [Enter] to return to the menu..."
    clear
done
