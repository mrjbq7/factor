! Copyright (C) 2024 Factor contributors
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax cairo.ffi classes.struct combinators
gobject-introspection gobject-introspection.standard-types
gobject-introspection.types kernel system vocabs ;
IN: gdk3.ffi

<<
"cairo.ffi" require
"pango.ffi" require
! Don't load pixbuf here - it should be independent
"gobject-introspection.types" require
>>

LIBRARY: gdk3

<<
"gdk3" {
    { [ os windows? ] [ "libgdk-3-0.dll" cdecl add-library ] }
    { [ os macos? ] [ drop ] }
    { [ os unix? ] [ "libgdk-3.so.0" cdecl add-library ] }
} cond
>>

C-TYPE: GdkScreen
C-TYPE: GdkWindow
C-TYPE: GdkDevice

! Define Cairo types for GTK3
STRUCT: cairo_rectangle_int_t
    { x int } { y int } { width int } { height int } ;

C-TYPE: cairo_region_t
C-TYPE: cairo_font_options_t  
C-TYPE: cairo_surface_t
C-TYPE: cairo_pattern_t
C-TYPE: cairo_t
C-TYPE: cairo_content_t

! Register Cairo types for GIR  
cairo_rectangle_int_t "cairo.RectangleInt" register-atomic-type
cairo_region_t "cairo.Region" register-atomic-type
cairo_font_options_t "cairo.FontOptions" register-atomic-type
cairo_surface_t "cairo.Surface" register-atomic-type
cairo_pattern_t "cairo.Pattern" register-atomic-type
cairo_t "cairo.Context" register-atomic-type
cairo_content_t "cairo.Content" register-atomic-type
cairo_format_t "cairo.Format" register-atomic-type

GIR: vocab:gir/Gdk-3.0.gir

! Additional functions for scaling support
C-TYPE: GdkMonitor
FUNCTION: GdkScreen* gdk_screen_get_default ( )
FUNCTION: gdouble gdk_screen_get_resolution ( GdkScreen* screen )
FUNCTION: gint gdk_window_get_scale_factor ( GdkWindow* window )
FUNCTION: GdkMonitor* gdk_screen_get_primary_monitor ( GdkScreen* screen )
FUNCTION: gint gdk_monitor_get_scale_factor ( GdkMonitor* monitor )