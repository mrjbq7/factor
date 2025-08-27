! Copyright (C) 2024 Factor contributors
! See https://factorcode.org/license.txt for BSD license.
USING: alien.libraries alien.syntax gobject-introspection
kernel system ;
IN: gdk3.pixbuf.ffi

LIBRARY: gdk3.pixbuf

<<
"gdk3.pixbuf" {
    { [ os windows? ] [ "libgdk_pixbuf-2.0-0.dll" cdecl add-library ] }
    { [ os macos? ] [ drop ] }
    { [ os unix? ] [ "libgdk_pixbuf-2.0.so.0" cdecl add-library ] }
} cond
>>

GIR: vocab:gir/GdkPixbuf-2.0.gir