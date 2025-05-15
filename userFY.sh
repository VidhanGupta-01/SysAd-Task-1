#!/bin/bash

# Only admin can run
if [ "$(whoami)" != "admin" ]; then
    echo "Only admin can run this script."
    exit 1
fi

# Parse YAML, assign blogs to users based on preferences, ensure even distribution
# Write results to /home/users/<username>/FYI.yaml
