

# Source the configuration file
if [[ -f "config.conf" ]]; then
    source "config.conf"
else
    echo "ERROR: config.conf not found." >&2
    exit 1
fi

# --- Logging Functions  ---
SCRIPT_NAME=$(basename "$0")

# This logs to the DEDICATED backup log
log_message() { echo "$(date '+%Y-%m-%d %H:%M:%S') [$SCRIPT_NAME] INFO: $1" >> "$BACKUP_LOG"; }

# Error log is still shared
log_error() { echo "$(date '+%Y-%m-%d %H:%M:%S') [$SCRIPT_NAME] ERROR: $1" >> "$ERROR_LOG"; echo "ERROR: $1" >&2; }
# --- End Logging ---

log_message "Backup process started."

# Error Handling : Check if source directory exists
if [[ ! -d "$SOURCE_DIR" ]]; then
    log_error "Source directory $SOURCE_DIR does not exist."
    exit 1
fi

# Check if the source directory is empty
if [ -z "$(ls -A "$SOURCE_DIR")" ]; then
    log_message "Source directory $SOURCE_DIR is empty. No backup needed."
    echo "Source directory $SOURCE_DIR is empty. No files to back up."
    exit 0 # Exit successfully, not an error
fi

# Error Handling : Ensure backup directory exists
mkdir -p "$BACKUP_DIR"
if [[ ! -d "$BACKUP_DIR" ]]; then
    log_error "Failed to create or find backup directory $BACKUP_DIR."
    exit 1
fi

# Create a timestamped archive name
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
DEST_FILE="$BACKUP_DIR/$ARCHIVE_NAME"

# Create the backup
tar -czf "$DEST_FILE" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"

# Error Handling : Check if tar command was successful
if [[ $? -eq 0 ]]; then
    log_message "Backup successful: $DEST_FILE"
    echo "Backup successful: $DEST_FILE"
    
    # Bonus Cleanup: Remove backups older than 7 days
    log_message "Cleaning up old backups..."
    find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -exec rm {} \;
    log_message "Cleanup complete."
else
    log_error "Backup failed."
    rm -f "$DEST_FILE" # Clean up partial archive
fi
