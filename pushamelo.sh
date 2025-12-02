#!/bin/bash

# Default commit message
DEFAULT_MESSAGE="quick updated"

# Function to display usage
usage() {
    echo
    echo "Usage: $0 [-m|--message] <commit_message>"
    echo "If no message is provided, the script will prompt interactively."
    echo
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--message)
            if [[ -n "$2" ]]; then
                MESSAGE="$2"
                shift 2
            else
                echo "Error: -m|--message requires a commit message."
                usage
            fi
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# If no message provided, prompt interactively
if [[ -z "$MESSAGE" ]]; then
    echo
    read -p "No commit message provided. Do you want to continue with the default '$DEFAULT_MESSAGE'? (y/n): " choice
    echo
    case "$choice" in
        y|Y ) MESSAGE="$DEFAULT_MESSAGE";;
        n|N ) 
            read -p "Enter commit message: " MESSAGE
            if [[ -z "$MESSAGE" ]]; then
                echo "No message entered. Exiting."
                exit 1
            fi
            ;;
        * ) echo "Invalid choice. Exiting."; exit 1;;
    esac
fi

# Execute git commands
git add .
git commit -m "$MESSAGE"
git push