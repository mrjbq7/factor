#!/bin/bash
# Build Factor with GTK3 from bootstrap image

echo "Building fresh Factor with GTK3 support..."

# Copy bootstrap image
cp boot.unix-x86.64.image factor-gtk3-bootstrap.image

# Bootstrap with GTK3 instead of GTK2
./factor -i=factor-gtk3-bootstrap.image -e='
USING: namespaces system vocabs.loader ;

os linux? [
    ! Load GTK3 backend instead of GTK2
    "ui.backend.gtk3" require
    
    ! Save the image
    "factor-gtk3.image" save-image-and-exit
] [
    "This is for Linux only" print
    1 exit
] if
'

if [ $? -eq 0 ]; then
    echo "GTK3 Factor image created: factor-gtk3.image"
    echo "Run with: ./factor -i=factor-gtk3.image"
else
    echo "Failed to create GTK3 image"
fi