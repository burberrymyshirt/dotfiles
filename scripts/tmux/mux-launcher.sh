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

    tmux rename-window -t "$SESSION_NAME:1" 'bash'
    tmux send-keys -t "$SESSION_NAME:1" 'lup' C-m

    tmux new-window -t "$SESSION_NAME:2" -n 'lazygit'
    tmux send-keys -t "$SESSION_NAME:2" 'ld && lazygit' C-m

    tmux new-window -t "$SESSION_NAME:3" -n 'nvim'
    tmux send-keys -t "$SESSION_NAME:3" 'nvim .' C-m

    # Select the first window by default
    tmux select-window -t "$SESSION_NAME:1"

    # Attach to the session
    tmux attach -t "$SESSION_NAME"
}

# Start the base session
setup_base_session

# Handle project-specific deviations
case "$PROJECT" in
    "cr")
        $CR_SCRIPT="coolrunner-setup.sh"
        if [ -f "$SESSIONS_SCRIPTS_DIR/$CR_SCRIPT" ]; then
            . "$SESSIONS_SCRIPTS_DIR/$CR_SCRIPT"
            setup_project1
        else
            echo "Error: $SESSIONS_SCRIPTS_DIR/$CR_SCRIPT not found."
            exit 1
        fi
        ;;
    "simz")
        $SIMZ_SCRIPT="coolrunner-setup.sh"
        if [ -f "$SESSIONS_SCRIPTS_DIR/$CR_SCRIPT" ]; then
            . "$SESSIONS_SCRIPTS_DIR/$CR_SCRIPT"
            setup_project1
        else
            echo "Error: $SESSIONS_SCRIPTS_DIR/$CR_SCRIPT not found."
            exit 1
        fi
        ;;
    *)
        echo "No specific project setup found. Running base setup."
        ;;
esac
