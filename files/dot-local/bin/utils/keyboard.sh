    #!/bin/sh

# Stateless keyboard layout toggle (Danish <-> US)

# Check if running under X11
if [ -z "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    exit 1
fi

# Get current active layout
current_layout=$(setxkbmap -print | grep xkb_symbols | awk -F'+' '{print $2}' | cut -d':' -f1)

# Toggle to the other layout
if [ "$current_layout" = "dk" ]; then
    setxkbmap -layout us,dk -model pc105 -option terminate:ctrl_alt_bksp,caps:escape
else
    setxkbmap -layout dk,us -model pc105 -option terminate:ctrl_alt_bksp,caps:escape  
fi

# Apply autorepeat settings
xset r rate 300 25
