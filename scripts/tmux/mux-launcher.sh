#!/usr/bin/env bash

# Default session name
DEFAULT_SESSION_NAME="basic_session"

# Use provided name or default
if [ -n "$1" ]; then
    SESSION_NAME="$1"
else
    SESSION_NAME="$DEFAULT_SESSION_NAME"
fi

# Check if the session already exists
if tmux list-sessions | grep -q "^$SESSION_NAME:"; then
    echo "Session $SESSION_NAME already exists. Attaching to it."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

PROJECT=$2
SESSIONS_SCRIPTS_DIR="$HOME/.local/bin/tmux-sessions"

# Base function to set up the session
setup_base_session() {
    tmux new-session -d -s "$SESSION_NAME"

    # Create the main editor window
    tmux rename-window -t "$SESSION_NAME:1" 'editor'
    tmux send-keys -t "$SESSION_NAME:1" 'nvim .' C-m

    # Create a server window
    tmux new-window -t "$SESSION_NAME:2" -n 'server'
    tmux send-keys -t "$SESSION_NAME:2" 'echo "Start your server here!"' C-m

    # Create a logs window
    tmux new-window -t "$SESSION_NAME:3" -n 'logs'
    tmux send-keys -t "$SESSION_NAME:3" 'tail -f /var/log/syslog' C-m

    # Select the editor window by default
    tmux select-window -t "$SESSION_NAME:1"

    # Attach to the session
    tmux attach -t "$SESSION_NAME"
}

# Start the base session
setup_base_session

# Handle project-specific deviations
case "$PROJECT" in
    "project1")
        if [ -f "$SESSIONS_SCRIPTS_DIR/coolrunner-setup.sh" ]; then
            . "$SESSIONS_SCRIPTS_DIR/coolrunner-setup.sh"
            setup_project1
        else
            echo "Error: $SESSIONS_SCRIPTS_DIR/coolrunner-setup.sh not found."
            exit 1
        fi
        ;;
    "project2")
        if [ -f "$SESSIONS_SCRIPTS_DIR/project2-setup.sh" ]; then
            . "$SESSIONS_SCRIPTS_DIR/project2-setup.sh"
            setup_project2
        else
            echo "Error: $SESSIONS_SCRIPTS_DIR/project2-setup.sh not found."
            exit 1
        fi
        ;;
    *)
        echo "No specific project setup found. Running base setup."
        ;;
esac
