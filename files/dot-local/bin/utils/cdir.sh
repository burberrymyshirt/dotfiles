#!/bin/sh

# Detect the current shell using the shell checker script
current_shell=$(ps -p $PPID -o comm=)

if test -z "$current_shell" 2>/dev/null; then
    echo "unknown shell"
    exit 1
fi

if [ "$current_shell" = "bash" ] || [ "$current_shell" = "zsh" ] || [ "$current_shell" = "sh" ] || [ "$current_shell" = "dash" ] || [ "$current_shell" = "ksh" ]; then
    cd "${_%/*}"
# elif [ "$current_shell" = "fish" ]; then
#     # Fish-specific syntax: Use dirname and status to change the directory
#     cd (dirname (status --current-filename))
else
    echo "Unsupported shell: $current_shell"
    exit 1
fi

exit 0
