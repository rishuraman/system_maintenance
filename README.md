Bash Scripting Suite for System Maintenance

This project is a modular and configurable suite of Bash scripts designed to automate common system maintenance tasks on Linux. It provides an interactive, menu-driven interface to run backups, perform system updates, and monitor logs, with all actions and errors captured in dedicated log files.

This suite was developed as a solution to the "Bash Scripting Suite for System Maintenance" assignment (LinuxOS and LSP).

## Features

- **Interactive Menu:** A simple, clean menu to navigate and execute all scripts.
- **Automated Backups:** Creates timestamped tar.gz archives of a specified directory.
- **System Updates:** Automates apt update, upgrade, autoremove, and clean (for Debian/Ubuntu-based systems).
- **Log Monitoring:** Scans specified log files for custom keywords (e.g., "failed", "successful").
- **Modular Structure:** All core logic is separated into individual scripts within the modules/ directory.
- **Centralized Configuration:** All paths and settings are managed in a single config.conf file.
- **Robust Logging:**
    - `logs/backup.log`: Records all backup operations.
    - `logs/maintenance.log`: Records update tasks and general suite operations.
    - `logs/error.log`: A central log for all errors from all scripts.

## Project Structure

```
system_maintenance/
├── config.conf           # Main configuration file (MUST EDIT)
├── main.sh               # The main executable script with menu
├── readme.md             # The file you are reading now
├── modules/              # Directory for task scripts
│   ├── backup.sh         # Backup script
│   ├── update.sh         # Update & cleanup script
│   └── monitor_logs.sh   # Log monitoring script
├── logs/                 # Directory for all log output
│   ├── backup.log
│   ├── maintenance.log
│   └── error.log
├── source_files/         # Example source directory for backups (configurable)
│   └── document1.txt
└── backup_drive/         # Example backup destination (configurable)
```

## Technologies Used

- **Bash:** The core scripting language.
- **Linux (Debian/Ubuntu-based):** The update script uses the apt package manager. Other scripts are POSIX-compliant.
- **Core Utilities:** tar, grep, find, mktemp.

## Setup and Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/system_maintenance.git
   cd system_maintenance
   ```

2. **Set Permissions:**
   You must make the main script and all modules executable:
   ```bash
   chmod +x main.sh modules/*.sh
   ```

3. **Configuration (Crucial Step):**
   Before running the suite, you must configure your settings in the `config.conf` file.

   - **Open the Config File:**
     ```bash
     nano config.conf
     ```

   - **Set Backup Paths:**
     The most important step is to set `SOURCE_DIR` and `BACKUP_DIR`.

     - **For Portable Testing (Recommended):**
       The default paths are set to use directories inside the project folder.
       ```bash
       SOURCE_DIR="$PWD/source_files"
       BACKUP_DIR="$PWD/backup_drive"
       ```
       To use this, make sure those directories exist and add some test files:
       ```bash
       mkdir -p source_files backup_drive
       echo "This is a test file." > source_files/test.txt
       ```

     - **For a Real System:**
       Point the paths to your actual system directories.
       ```bash
       # Example: Back up your Documents folder
       SOURCE_DIR="/home/user/Documents"

       # Example: Save to an external drive
       BACKUP_DIR="/mnt/my_external_drive/backups"
       ```

   - **Review Other Settings:**
     You can also change which log file is monitored and which keywords to search for. The default monitors `logs/backup.log` for "failed" or "successful".
     ```bash
     LOG_FILE_TO_MONITOR="logs/backup.log"
     MONITOR_KEYWORDS="failed successful"
     ```

## Execution

To run the suite, simply execute the main script from the project's root directory:

```bash
./main.sh
```

## Menu Options

1.  **Run System Backup:** Creates a compressed backup of your `SOURCE_DIR`.
2.  **Run System Update & Cleanup:** (Requires sudo) Runs the full apt update and cleanup sequence.
3.  **Monitor Backup Logs:** Scans the `backup.log` for keywords defined in `config.conf`.
4.  **View Maintenance Log:** Displays the last 15 lines of the general maintenance log.
5.  **View Error Log:** Displays the last 15 lines of the error log.
6.  **View Backup Log:** Displays the last 15 lines of the backup-specific log.
**Q. Quit:** Exits the script.