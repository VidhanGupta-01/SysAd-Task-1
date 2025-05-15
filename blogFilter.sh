#!/bin/bash

mod=$(whoami)
blacklist="/home/mods/$mod/blacklist.txt"

for author in $(ls /home/authors); do
    pubdir="/home/authors/$author/public"
    for blog in "$pubdir"/*; do
        count=0
        while IFS= read -r word; do
            matches=$(grep -i -o -P "$word" "$blog" | wc -l)
            if [ $matches -gt 0 ]; then
                count=$((count + matches))
                # Replace with asterisks
                sed -i "s/$word/$(printf '%*s' ${#word} | tr ' ' '*')/Ig" "$blog"
                # Print each occurrence
            fi
        done < "$blacklist"
        if [ $count -gt 5 ]; then
            # Archive blog, remove symlink, update YAML
            echo "Blog $(basename $blog) is archived due to excessive blacklisted words."
        fi
    done
done
