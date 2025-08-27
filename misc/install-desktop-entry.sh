#!/bin/bash

# Install Factor desktop entry and icons for current user
# Run this from the extracted Factor directory: ./misc/install-desktop-entry.sh

FACTOR_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESKTOP_FILE="$FACTOR_ROOT/misc/factor.desktop"
ICON_SOURCE="$FACTOR_ROOT/misc/icons/icon.svg"

# Create directories if they don't exist
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/icons/hicolor/scalable/apps

# Copy and update the desktop file with the correct path
sed "s|Exec=factor|Exec=$FACTOR_ROOT/factor|g" "$DESKTOP_FILE" > ~/.local/share/applications/factor.desktop

# Copy the icon
cp "$ICON_SOURCE" ~/.local/share/icons/hicolor/scalable/apps/factor.svg

# Also copy PNG versions for better compatibility
for size in 16 32 48 64 128 256 512; do
    if [ -f "$FACTOR_ROOT/misc/icons/icon_${size}x${size}.png" ]; then
        mkdir -p ~/.local/share/icons/hicolor/${size}x${size}/apps
        cp "$FACTOR_ROOT/misc/icons/icon_${size}x${size}.png" ~/.local/share/icons/hicolor/${size}x${size}/apps/factor.png
    fi
done

# Update desktop database
update-desktop-database ~/.local/share/applications/ 2>/dev/null

# Update icon cache
gtk-update-icon-cache -f ~/.local/share/icons/hicolor/ 2>/dev/null || true

echo "Factor desktop entry installed successfully!"
echo "You may need to log out and back in for the changes to take full effect."