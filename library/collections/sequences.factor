! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel math strings vectors ;

! This file is needed very early in bootstrap.

! Sequences support the following protocol. Concrete examples
! are strings, string buffers, vectors, and arrays. Arrays are
! low level and not bounds-checked; they are in the
! kernel-internals vocabulary, so don't use them unless you have
! a good reason.

GENERIC: empty? ( sequence -- ? )
GENERIC: length ( sequence -- n )
GENERIC: set-length ( n sequence -- )
GENERIC: ensure-capacity ( n sequence -- )
GENERIC: nth ( n sequence -- obj )
GENERIC: set-nth ( value n sequence -- obj )
GENERIC: thaw ( seq -- mutable-seq )
GENERIC: freeze ( new orig -- new )
GENERIC: reverse ( seq -- seq )

DEFER: append ! remove this when sort is moved from lists to sequences
