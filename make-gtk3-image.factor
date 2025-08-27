! Script to create a GTK3-based Factor image
USING: command-line io io.pathnames kernel namespaces sequences
system ui.backend ui.backend.gtk3 vocabs.loader ;
IN: make-gtk3-image

: make-gtk3-image ( -- )
    "Creating GTK3 Factor image..." print
    
    ! Don't load the default UI backend
    f "ui-backend" set-global
    
    ! Set GTK3 as the UI backend
    gtk3-ui-backend ui-backend set-global
    
    "factor-gtk3.image" save-image-and-exit ;

MAIN: make-gtk3-image