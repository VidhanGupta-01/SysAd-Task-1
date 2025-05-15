#!/bin/bash

AUTHOR=$(whoami)
BASE_DIR="/home/authors/$AUTHOR"
BLOGS_DIR="$BASE_DIR/blogs"
PUBLIC_DIR="$BASE_DIR/public"
YAML_FILE="$BASE_DIR/blogs.yaml"

# Categories
CATEGORIES=("Technology" "Cinema" "Sports" "Finance" "Lifestyle")

update_yaml() {
    local filename=$1
    local status=$2
    local categories=("${@:3}")
    local category_list=$(printf ", %s" "${categories[@]}")
    category_list="[${category_list:2}]"

    if yq e ".blogs[] | select(.name == \"$filename\")" "$YAML_FILE" >/dev/null; then
        yq e -i "(.blogs[] | select(.name == \"$filename\")).publish_status = $status" "$YAML_FILE"
        yq e -i "(.blogs[] | select(.name == \"$filename\")).categories = $category_list" "$YAML_FILE"
    else
        yq e -i ".blogs += [{name: \"$filename\", publish_status: $status, categories: $category_list}]" "$YAML_FILE"
    fi
}

case $1 in
    -p)  # Publish
        echo "Publishing $2"
        echo "Select category order (e.g. 2,1 for ${CATEGORIES[1]} and ${CATEGORIES[0]}): "
        read order
        IFS=',' read -r -a prefs <<< "$order"
        selected=()
        for idx in "${prefs[@]}"; do
            selected+=("${CATEGORIES[$((idx-1))]}")
        done

        ln -s "$BLOGS_DIR/$2" "$PUBLIC_DIR/$2"
        chmod o+r "$PUBLIC_DIR/$2"
        update_yaml "$2" true "${selected[@]}"
        echo "Blog published."
        ;;

    -a)  # Archive
        echo "Archiving $2"
        rm -f "$PUBLIC_DIR/$2"
        update_yaml "$2" false
        echo "Blog archived."
        ;;

    -d)  # Delete
        echo "Deleting $2"
        rm -f "$BLOGS_DIR/$2"
        rm -f "$PUBLIC_DIR/$2"
        yq e -i "del(.blogs[] | select(.name == \"$2\"))" "$YAML_FILE"
        echo "Blog deleted."
        ;;

    -e)  # Edit categories
        echo "Editing categories for $2"
        echo "Select new category order:"
        for i in "${!CATEGORIES[@]}"; do
            echo "$((i+1)). ${CATEGORIES[$i]}"
        done
        read new_order
        IFS=',' read -r -a new_prefs <<< "$new_order"
        new_selected=()
        for idx in "${new_prefs[@]}"; do
            new_selected+=("${CATEGORIES[$((idx-1))]}")
        done
        update_yaml "$2" true "${new_selected[@]}"
        echo "Categories updated."
        ;;

    *)
        echo "Usage: $0 [-p|-a|-d|-e] <filename>"
        ;;
esac
