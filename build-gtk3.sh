#!/bin/bash
# Build Factor with GTK3 support

echo "Building Factor with GTK3..."

# Start with a minimal image that doesn't have GTK2 loaded
./factor -e='
USING: namespaces ui.backend ui.backend.gtk3 system vocabs.loader ;

! Set GTK3 as the default UI backend
gtk3-ui-backend ui-backend set-global

! Save the image
"factor-gtk3.image" save-image-and-exit
'

echo "GTK3 Factor image created: factor-gtk3.image"
echo "Run with: ./factor -i=factor-gtk3.image"