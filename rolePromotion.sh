#!/bin/bash

# Paths
REQUESTS_FILE="/home/admin/requests.yaml"
NEW_AUTHOR_DIR="/home/authors"
ADMIN_GROUP="g_author"

# Add user to requests.yaml for promotion
request_author_role() {
    local username=$1
    if ! grep -q "$username" "$REQUESTS_FILE"; then
        echo "$username" >> "$REQUESTS_FILE"
        echo "$username has requested author role."
    else
        echo "Request already exists for $username."
    fi
}

# Admin approves a user for promotion
approve_request() {
    local username=$1
    local author_dir="$NEW_AUTHOR_DIR/$username"

    # Move user to author directory
    mv "/home/users/$username" "$author_dir"
    usermod -g "$ADMIN_GROUP" "$username"

    # Create necessary directories for the new author
    mkdir -p "$author_dir/blogs" "$author_dir/public"
    chown -R "$username:$ADMIN_GROUP" "$author_dir"

    echo "User $username has been promoted to author."
    # Remove the request from the YAML file
    sed -i "/$username/d" "$REQUESTS_FILE"
}

# Example Usage
# request_author_role "user1"
# approve_request "user1"
        
