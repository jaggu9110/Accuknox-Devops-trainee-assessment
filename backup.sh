#!/bin/bash

# Configuration
SOURCE_DIR="/path/to/source/directory"  # Directory to back up
REMOTE_USER="username"                  # Remote server username
REMOTE_HOST="remote.server.com"         # Remote server address
REMOTE_DIR="/path/to/remote/backup"     # Remote directory to store the backup
LOG_FILE="/var/log/backup.log"          # Log file location

# Create a timestamp for the backup
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/tmp/backup_$DATE"

# Ensure the log file exists and is writable
touch $LOG_FILE
chmod 644 $LOG_FILE

# Create a temporary directory for the backup
mkdir -p $BACKUP_DIR

# Start the backup process
echo "[$(date)] Starting backup of $SOURCE_DIR" | tee -a $LOG_FILE

# Perform the backup using rsync
rsync -av --delete $SOURCE_DIR/ $BACKUP_DIR/ &>> $LOG_FILE

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "[$(date)] Backup created successfully at $BACKUP_DIR" | tee -a $LOG_FILE
else
    echo "[$(date)] ERROR: Failed to create backup" | tee -a $LOG_FILE
    exit 1
fi

# Transfer the backup to the remote server
echo "[$(date)] Transferring backup to $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" | tee -a $LOG_FILE
rsync -av $BACKUP_DIR/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/ &>> $LOG_FILE

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "[$(date)] Backup transferred successfully to $REMOTE_HOST:$REMOTE_DIR" | tee -a $LOG_FILE
else
    echo "[$(date)] ERROR: Failed to transfer backup to remote server" | tee -a $LOG_FILE
    exit 1
fi

# Clean up local backup directory
rm -rf $BACKUP_DIR

echo "[$(date)] Backup process completed successfully" | tee -a $LOG_FILE
