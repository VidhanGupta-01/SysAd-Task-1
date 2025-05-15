#!/bin/bash

# Paths
NOTIFICATIONS_DIR="/home/users/$USER/notifications.log"
NOTIFY_SERVER="localhost"
PORT=12345

# Send notification via Netcat
send_notification() {
    local user=$1
    local message=$2
    echo "$message" | nc -q 1 $NOTIFY_SERVER $PORT
}

# Notify subscribed users
notify_subscribed_users() {
    local author=$1
    local article=$2
    local message="New article published by $author: $article"

    for user in $(cat /home/users/$USER/subscribed_users); do
        send_notification $user "$message"
    done
}

# Check unread notifications and display count
check_unread_notifications() {
    local user=$1
    local unread_count=$(grep -c "new_notifications" "$NOTIFICATIONS_DIR")
    if [ "$unread_count" -gt 0 ]; then
        echo "You have $unread_count unread notifications."
    else
        echo "No new notifications."
    fi
}

# Cronjob check for new notifications and display count
check_unread_notifications $USER
