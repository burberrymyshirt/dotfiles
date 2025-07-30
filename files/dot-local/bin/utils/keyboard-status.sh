if [ -z "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    exit 1
fi

# Get current active layout
current_layout=$(setxkbmap -print | grep xkb_symbols | awk -F'+' '{print $2}' | cut -d':' -f1)

# Output flag based on current layout
case "$current_layout" in
    "dk")
        echo "🇩🇰"
        ;;
    "us")
        echo "🇺🇸"
        ;;
    *)
        echo "⌨️"  # fallback
        ;;
esac
