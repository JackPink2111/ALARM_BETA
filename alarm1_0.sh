#!/bin/bash

echo
echo "ALARM1 _ 0" |figlet -f big | lolcat -i 
echo
"fortune"
echo
# Get alarm time from user
read -p "Enter alarm time in 24 hours (HH:MM): " alarm_time

# Function to play alarm sound
play_alarm() {
    for i in {1..5}; do
        paplay /home/jack/Downloads/panchadhara-bomma-1911.mp3  # Replace with your alarm sound file
        sleep 2
    done
}

# Function to display countdown timer
display_countdown() {
    while [ $seconds -gt 0 ]; do
        echo -ne "\rAlarm in: $(date -u -d @$seconds +%H:%M:%S)"
        sleep 1
        seconds=$((seconds - 1))
    done
}

# Function to check for snooze
check_snooze() {
    read -n 1 -p "Snooze (y/n)? " snooze
    if [[ $snooze =~ ^[Yy]$ ]]; then
        seconds=900  # Set snooze duration
        display_countdown
        play_alarm
    fi
}

# Convert alarm time to seconds
alarm_seconds=$(date -d "$alarm_time" +%s)
current_seconds=$(date +%s)
seconds=$((alarm_seconds - current_seconds))

# Display countdown timer
display_countdown &

# Wait for alarm time and play sound
sleep $seconds
play_alarm

# Check for snooze
check_snooze

# Persist alarm across shutdowns (requires systemd)
if [[ $(systemctl is-active alarm.service) == "inactive" ]]; then
    systemd-run --user --on-calendar="$alarm_time" $0
fi

