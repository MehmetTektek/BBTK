#!/bin/bash

# Script Name: TemporaryAdmin.sh
# Description: Provides temporary admin rights to the Self Service user directly.
# Author: Mehmet Ceylan Tektek
# Date: 28/03/2025

# Configuration
duration_minutes="$1" # Duration in minutes from Parameter 1
duration_seconds=$((duration_minutes * 60)) # Convert minutes to seconds
log_file="/var/log/temporary_admin.log"

# Function to log messages
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Get the current user
admin_user=$(stat -f "%Su" /dev/console)

# Check if parameters are provided
if [[ -z "$duration_minutes" ]]; then
  log "Error: Missing duration parameter. Usage: $0 <duration_minutes>"
  echo "Error: Missing duration parameter. Please provide duration."
  exit 1
fi

# Check if the user exists
if dscl . -read /Users/"$admin_user" > /dev/null; then
  log "User '$admin_user' exists."
else
  log "Error: User '$admin_user' does not exist."
  echo "Error: User '$admin_user' does not exist."
  exit 1
fi

# Add the user to the admin group
dseditgroup -o edit -a "$admin_user" admin
if [[ $? -eq 0 ]]; then
  log "User '$admin_user' added to admin group."
  echo "Admin rights granted to '$admin_user' for $duration_minutes minutes."
else
  log "Error adding user '$admin_user' to admin group."
  echo "Error granting admin rights. Please check the log for details."
  exit 1
fi

# Schedule the removal of the user from the admin group
(sleep "$duration_seconds"; dseditgroup -o edit -d "$admin_user" admin; log "User '$admin_user' removed from admin group.") &

log "Temporary admin rights granted successfully."
exit 0

