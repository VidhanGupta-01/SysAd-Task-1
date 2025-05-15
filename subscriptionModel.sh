#!/bin/bash

# Paths
SUBSCRIPTION_FILE="/home/admin/subscriptions.yaml"
BLOGS_DIR="/home/authors"
USER_DIR="/home/users"
BLOGS_YAML="/home/authors/$USER/blogs.yaml"

# Create the subscription file if it doesn't exist
if [ ! -f "$SUBSCRIPTION_FILE" ]; then
    echo "Creating subscription data file."
    touch "$SUBSCRIPTION_FILE"
fi

# Subscribe a user to an author
subscribe_user() {
    local username=$1
    local author=$2
    if ! grep -q "$author" "$SUBSCRIPTION_FILE"; then
        echo "$username has subscribed to $author" >> "$SUBSCRIPTION_FILE"
        mkdir -p "/home/users/$username/subscribed_blogs"
        ln -s "/home/authors/$author/public" "/home/users/$username/subscribed_blogs/$author"
        echo "$username is now subscribed to $author"
    else
        echo "User is already subscribed to $author."
    fi
}

# Authors can publish articles as public or subscribers-only
publish_article() {
    local author=$1
    local filename=$2
    local is_subscribers_only=$3
    local blog_path="/home/authors/$author/blogs/$filename"

    if [ "$is_subscribers_only" == "true" ]; then
        # Mark article as subscribers-only
        echo "Publishing $filename as subscribers-only."
        ln -s "$blog_path" "/home/authors/$author/subscribers_only/$filename"
    else
        # Publish publicly
        ln -s "$blog_path" "/home/public/$filename"
    fi
}

# Example Usage
# subscribe_user "user1" "author1"
# publish_article "author1" "article1.txt" true
