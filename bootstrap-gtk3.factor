! Bootstrap script for GTK3 Factor
! Run with: ./factor -run=bootstrap-gtk3

USING: init io kernel namespaces system ui.backend vocabs.loader ;
IN: bootstrap-gtk3

! Prevent GTK2 from loading by not loading ui.backend.gtk2
! which sets itself as default on Linux

os linux? [
    ! Override the UI backend selection before GTK2 loads
    "ui.backend.gtk3" require
    
    ! The GTK3 backend should have set itself as default
    ! Save the new image
    "factor-gtk3.image" save-image-and-exit
] [
    "This script is for Linux only" print
] if