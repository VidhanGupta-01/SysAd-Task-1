#!/bin/bash

# Paths
USERS_YAML="users.yaml"
ALL_BLOGS_DIR="/home/users/all_blogs"

# Required groups
GROUPS=("g_user" "g_author" "g_mod" "g_admin")

# Create necessary groups
for group in "${GROUPS[@]}"; do
    if ! getent group "$group" > /dev/null; then
        sudo groupadd "$group"
    fi
done

# Create users and assign groups
create_user() {
    username=$1
    role=$2
    home_dir=$3

    # Create user if not exists
    if ! id "$username" &>/dev/null; then
        sudo useradd -m -d "$home_dir" -g "g_$role" "$username"
        echo "[+] Created $username with home $home_dir and group g_$role"
    else
        echo "[i] $username already exists"
    fi

    # Create role-specific directories
    if [ "$role" = "author" ]; then
        mkdir -p "$home_dir/blogs" "$home_dir/public"
        sudo chown -R "$username:g_author" "$home_dir"
    elif [ "$role" = "user" ]; then
        mkdir -p "$ALL_BLOGS_DIR"
        ln -snf "$ALL_BLOGS_DIR" "$home_dir/all_blogs"
        sudo chown -R "$username:g_user" "$home_dir"
    elif [ "$role" = "mod" ]; then
        sudo chown -R "$username:g_mod" "$home_dir"
    elif [ "$role" = "admin" ]; then
        sudo chown -R "$username:g_admin" "$home_dir"
    fi

    chmod 700 "$home_dir"
}

# Parse YAML and create users
parse_yaml() {
    role=$1
    if [ "$role" = "admin" ]; then
    base_dir="/home/admin"
    else
    base_dir="/home/${role}s"
    fi

    mkdir -p "$base_dir"

    yq e ".${role}s[]" "$USERS_YAML" | while read -r user; do
        create_user "$user" "$role" "$base_dir/$user"
    done
}

# MAIN

parse_yaml "user"
parse_yaml "author"
parse_yaml "mod"
parse_yaml "admin"

echo "[+] All users and directories set up successfully."

# Moderator-specific access to authors' public directories
for mod_entry in $(yq -r '.mods[] | @base64' "$yaml_file"); do
    mod_name=$(echo "$mod_entry" | base64 --decode | yq -r '.name')
    mod_home="/home/mods/$mod_name"

    # Ensure moderator user exists before proceeding
    if id "$mod_name" &>/dev/null; then
        assigned_authors=$(echo "$mod_entry" | base64 --decode | yq -r '.assigned_authors[]')

        for author in $assigned_authors; do
            public_dir="/home/authors/$author/public"

            if [ -d "$public_dir" ]; then
                # Grant read and write access using ACL (best option)
                setfacl -m u:$mod_name:rw "$public_dir"
                echo "Granted $mod_name access to $author's public directory"
            else
                echo "Public directory for author $author does not exist, skipping..."
            fi
        done
    fi
done


# Create all_blogs directory and symlinks for each user
for user in $(yq -r '.users[]' "$yaml_file"); do
    user_home="/home/users/$user"
    blogs_dir="$user_home/all_blogs"

    # Create all_blogs directory if not exists
    mkdir -p "$blogs_dir"
    chown "$user:g_user" "$blogs_dir"
    chmod 755 "$blogs_dir"

    for author in $(yq -r '.authors[]' "$yaml_file"); do
        author_public="/home/authors/$author/public"
        link_target="$blogs_dir/$author"

        # Create symlink only if public dir exists
        if [ -d "$author_public" ]; then
            ln -sf "$author_public" "$link_target"
            chown -h "$user:g_user" "$link_target"
        fi
    done
done


# Grant admins full access to all user/author/mod home directories
for admin in $(yq -r '.admins[]' "$yaml_file"); do
    for dir_group in users authors mods; do
        for target_dir in /home/$dir_group/*; do
            if [ -d "$target_dir" ]; then
                setfacl -Rm u:$admin:rwx "$target_dir"
                echo "Granted admin $admin full access to $target_dir"
            fi
        done
    done
done
