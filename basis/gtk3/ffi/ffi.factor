! Copyright (C) 2024 Factor contributors
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
gobject-introspection kernel system vocabs ;
IN: gtk3.ffi

<<
"gdk3.ffi" require
"atk.ffi" require
>>

LIBRARY: gtk3

<<
"gtk3" {
    { [ os windows? ] [ "libgtk-3-0.dll" cdecl add-library ] }
    { [ os macos? ] [ drop ] }
    { [ os unix? ] [ "libgtk-3.so.0" cdecl add-library ] }
} cond
>>

GIR: vocab:gir/Gtk-3.0.gir