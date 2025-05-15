#!/bin/bash

# Only allow admin
if [ "$(whoami)" != "admin" ]; then
    echo "Only admin can run this script."
    exit 1
fi

REPORT_DIR="/home/admin/reports"
mkdir -p "$REPORT_DIR"
REPORT_FILE="$REPORT_DIR/report_$(date +%F_%H-%M-%S).txt"

echo "Generating admin report..." > "$REPORT_FILE"
echo "==========================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Published and deleted articles by tag
echo "Published and Deleted Articles by Tags:" >> "$REPORT_FILE"
declare -A tag_count_published
declare -A tag_count_deleted

for author in /home/authors/*; do
    yaml="$author/blogs.yaml"
    if [ -f "$yaml" ]; then
        yq e '.blogs[]' "$yaml" | while read -r blog; do
            title=$(echo "$blog" | yq e '.title' -)
            status=$(echo "$blog" | yq e '.publish_status' -)
            tags=$(echo "$blog" | yq e '.categories[]' -)

            for tag in $tags; do
                if [ "$status" == "true" ]; then
                    tag_count_published["$tag"]=$((tag_count_published["$tag"] + 1))
                else
                    tag_count_deleted["$tag"]=$((tag_count_deleted["$tag"] + 1))
                fi
            done
        done
    fi
done

echo "Published Articles:" >> "$REPORT_FILE"
for tag in "${!tag_count_published[@]}"; do
    echo "$tag: ${tag_count_published[$tag]}" >> "$REPORT_FILE"
done

echo "" >> "$REPORT_FILE"
echo "Deleted Articles:" >> "$REPORT_FILE"
for tag in "${!tag_count_deleted[@]}"; do
    echo "$tag: ${tag_count_deleted[$tag]}" >> "$REPORT_FILE"
done

echo "" >> "$REPORT_FILE"
echo "Top 3 Most Read Articles:" >> "$REPORT_FILE"
echo "=========================" >> "$REPORT_FILE"

# Read count tracking
declare -A read_counts

for file in /home/authors/*/blogs/*; do
    if [ -f "$file" ]; then
        basename=$(basename "$file")
        count_file="$file.readcount"
        if [ -f "$count_file" ]; then
            count=$(cat "$count_file")
        else
            count=0
        fi
        read_counts["$basename"]=$count
    fi
done

for article in "${!read_counts[@]}"; do
    echo "$article: ${read_counts[$article]}"
done | sort -k2 -nr | head -n 3 >> "$REPORT_FILE"

echo "Report saved to $REPORT_FILE"
