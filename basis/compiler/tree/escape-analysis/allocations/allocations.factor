! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs namespaces sequences kernel math
combinators sets disjoint-sets fry locals stack-checker.values ;
FROM: namespaces => set ;
IN: compiler.tree.escape-analysis.allocations

! A map from values to classes. Only for #introduce outputs
SYMBOL: value-classes

: value-class ( value -- class ) value-classes get at ;

: set-value-class ( class value -- ) value-classes get set-at ;

! A map from values to one of the following:
! - f -- initial status, assigned to values we have not seen yet;
!        may potentially become an allocation later
! - a sequence of values -- potentially unboxed tuple allocations
! - t -- not allocated in this procedure, can never be unboxed
SYMBOL: allocations

: allocation ( value -- allocation )
    allocations get at ;

: record-allocation ( allocation value -- )
    allocations get set-at ;

: record-allocations ( allocations values -- )
    allocations get [ set-at ] curry 2each ;

! We track slot access to connect constructor inputs with
! accessor outputs.
SYMBOL: slot-accesses

TUPLE: slot-access slot# value ;

C: <slot-access> slot-access

: record-slot-access ( out slot# in -- )
    <slot-access> swap slot-accesses get set-at ;

! We track escaping values with a disjoint set.
SYMBOL: escaping-values

SYMBOL: +escaping+

: <escaping-values> ( -- disjoint-set )
    <disjoint-set> +escaping+ over add-atom ;

: init-escaping-values ( -- )
    <escaping-values> escaping-values set ;

: (introduce-value) ( values assoc -- )
    2dup disjoint-set-member?
    [ 2drop ] [ add-atom ] if ;

: introduce-value ( values -- )
    escaping-values get (introduce-value) ;

: introduce-values ( values -- )
    escaping-values get [ (introduce-value) ] curry each ;

: <slot-value> ( -- value )
    <value> dup introduce-value ;

: merge-values ( in-values out-value -- )
    escaping-values get equate-all-with ;

: merge-slots ( values -- value )
    <slot-value> [ merge-values ] keep ;

: equate-values ( value1 value2 -- )
    escaping-values get equate ;

DEFER: add-escaping-values

: add-escaping-value ( value -- )
    [ allocation dup boolean? [ drop ] [ add-escaping-values ] if ]
    [ +escaping+ equate-values ]
    bi ;

: add-escaping-values ( values -- )
    [ add-escaping-value ] each ;

: unknown-allocation ( value -- )
    [ add-escaping-value ]
    [ t swap record-allocation ]
    bi ;

: unknown-allocations ( values -- )
    [ unknown-allocation ] each ;

: escaping-value? ( value -- ? )
    +escaping+ escaping-values get equiv? ;

DEFER: copy-value

: copy-allocation ( allocation -- allocation' )
    dup boolean? [
        [ <value> [ introduce-value ] [ copy-value ] [ ] tri ] map
    ] unless ;

:: (copy-value) ( from to assoc -- )
    from to equate-values
    from assoc at copy-allocation to assoc set-at ;

: copy-value ( from to -- )
    allocations get (copy-value) ;

: copy-values ( from to -- )
    allocations get [ (copy-value) ] curry 2each ;

: copy-slot-value ( out slot# in -- )
    allocation dup boolean?
    [ 3drop ] [ nth swap copy-value ] if ;

! Compute which tuples escape
SYMBOL: escaping-allocations

: compute-escaping-allocations ( -- )
    allocations get
    [ drop escaping-value? ] assoc-filter
    escaping-allocations set ;

: escaping-allocation? ( value -- ? )
    escaping-allocations get key? ;

: unboxed-allocation ( value -- allocation/f )
    dup escaping-allocation? [ drop f ] [ allocation ] if ;

: unboxed-slot-access? ( value -- ? )
    slot-accesses get at*
    [ value>> unboxed-allocation >boolean ] when ;
