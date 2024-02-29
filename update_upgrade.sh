#!/bin/bash

# Update package repositories
sudo apt update

# Check if there are changes that require explicit acceptance
if grep -q "N: This must be accepted explicitly before updates" /var/log/apt/term.log; then
    # Display a prompt to accept changes before continuing with the update
    zenity --question --title="Repository Changes" --text="Changes in repositories require explicit acceptance. Do you want to accept these changes and continue updating?" --width=400 --height=200

    # Check user response
    if [ $? -eq 0 ]; then
        # If user accepts, proceed with the upgrade
        sudo apt upgrade -y
    else
        # If user declines, display a message and exit
        zenity --info --title="Update Aborted" --text="Update process aborted. Changes in repositories were not accepted."
        exit 0
    fi
else
    # If no changes requiring explicit acceptance, proceed with the upgrade
    sudo apt upgrade -y
fi

# Check the exit status of the upgrade process
if [ $? -eq 0 ]; then
    # If the exit status is 0 (indicating success), display a popup window
    zenity --info --title="Update/Upgrade Successful" --text="The system update and upgrade process completed successfully."
else
    # If the exit status is not 0 (indicating failure), retrieve and display error logs
    error_logs="/var/log/apt/*"
    error_message="An error occurred during the system update and upgrade process. Please check the logs for more information."

    # Check if error logs exist
    if ls $error_logs 1> /dev/null 2>&1; then
        # Display error logs using a text viewer
        zenity --error --title="Update/Upgrade Error" --text="$error_message" --width=400 --height=300 --text-info --filename="$error_logs"
    else
        # If no error logs are found, display a generic error message
        zenity --error --title="Update/Upgrade Error" --text="$error_message"
    fi
fi
