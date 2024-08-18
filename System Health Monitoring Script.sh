#!/bin/bash

# Define thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

# Define log file
LOG_FILE="/var/log/system_health.log"

# Function to log messages
log_message() {
    local message=$1
    echo "$(date): $message" >> $LOG_FILE
}

# Check CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    log_message "WARNING: CPU usage is above threshold: $CPU_USAGE%"
fi

# Check memory usage
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
    log_message "WARNING: Memory usage is above threshold: $MEMORY_USAGE%"
fi

# Check disk space usage
DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
if (( DISK_USAGE > DISK_THRESHOLD )); then
    log_message "WARNING: Disk space usage is above threshold: $DISK_USAGE%"
fi

# Check running processes (e.g., number of processes)
PROCESS_COUNT=$(ps aux | wc -l)
if (( PROCESS_COUNT > 200 )); then
    log_message "WARNING: Number of running processes is high: $PROCESS_COUNT"
fi
