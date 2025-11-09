
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

log_message "Log monitoring started."

# Error Handling : Check if log file exists
if [[ ! -f "$LOG_FILE_TO_MONITOR" ]]; then
    log_error "Log file $LOG_FILE_TO_MONITOR not found."
    exit 1
fi

# Convert space-separated keywords to a grep-compatible regex (e.g., "error|critical|failed")
REGEX_KEYWORDS=$(echo "$MONITOR_KEYWORDS" | tr ' ' '|')

echo "Scanning $LOG_FILE_TO_MONITOR for keywords: $MONITOR_KEYWORDS"

# Search for keywords, case-insensitive
# We use a temp file to store findings
FINDINGS_FILE=$(mktemp)
grep -E -i "$REGEX_KEYWORDS" "$LOG_FILE_TO_MONITOR" > "$FINDINGS_FILE"

# Check if the findings file has any content
if [[ -s "$FINDINGS_FILE" ]]; then
    log_message "ALERT: Critical keywords found in $LOG_FILE_TO_MONITOR."
    echo "---"
    echo "ALERT: Keywords found in $LOG_FILE_TO_MONITOR"
    echo "---"
    # Display the findings (last 10 lines)
    tail -n 10 "$FINDINGS_FILE"
    echo "---"
    echo "Full findings logged to $LOG_FILE."
    # Log the full findings
    cat "$FINDINGS_FILE" >> "$LOG_FILE"
else
    log_message "No critical issues found."
    echo "No keywords found in $LOG_FILE_TO_MONITOR."
fi

# Clean up the temp file
rm "$FINDINGS_FILE"
log_message "Log monitoring finished."
