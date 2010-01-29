! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel continuations assocs namespaces
sequences words vocabs definitions hashtables init sets
math math.order classes classes.algebra classes.tuple
classes.tuple.private generic source-files.errors
kernel.private ;
IN: compiler.units

SYMBOL: old-definitions
SYMBOL: new-definitions

TUPLE: redefine-error def ;

: redefine-error ( definition -- )
    \ redefine-error boa
    { { "Continue" t } } throw-restarts drop ;

<PRIVATE

: add-once ( key assoc -- )
    2dup key? [ over redefine-error ] when conjoin ;

: (remember-definition) ( definition loc assoc -- )
    [ over set-where ] dip add-once ;

PRIVATE>

: remember-definition ( definition loc -- )
    new-definitions get first (remember-definition) ;

: fake-definition ( definition -- )
    old-definitions get [ delete-at ] with each ;

: remember-class ( class loc -- )
    [ dup new-definitions get first key? [ dup redefine-error ] when ] dip
    new-definitions get second (remember-definition) ;

: forward-reference? ( word -- ? )
    dup old-definitions get assoc-stack
    [ new-definitions get assoc-stack not ]
    [ drop f ] if ;

SYMBOL: compiler-impl

HOOK: update-call-sites compiler-impl ( class generic -- words )

: changed-call-sites ( class generic -- )
    update-call-sites [ changed-definition ] each ;

M: generic update-generic ( class generic -- )
    [ changed-call-sites ]
    [ remake-generic drop ]
    2bi ;

M: sequence update-methods ( class seq -- )
    implementors [ update-generic ] with each ;

HOOK: recompile compiler-impl ( words -- alist )

HOOK: to-recompile compiler-impl ( -- words )

HOOK: process-forgotten-words compiler-impl ( words -- )

: compile ( words -- ) recompile modify-code-heap ;

! Non-optimizing compiler
M: f update-call-sites
    2drop { } ;

M: f to-recompile
    changed-definitions get [ drop word? ] assoc-filter keys ;

M: f recompile
    [ dup def>> ] { } map>assoc ;

M: f process-forgotten-words drop ;

: without-optimizer ( quot -- )
    [ f compiler-impl ] dip with-variable ; inline

: <definitions> ( -- pair ) { H{ } H{ } } [ clone ] map ;

SYMBOL: definition-observers

GENERIC: definitions-changed ( assoc obj -- )

[ V{ } clone definition-observers set-global ]
"compiler.units" add-startup-hook

! This goes here because vocabs cannot depend on init
[ V{ } clone vocab-observers set-global ]
"vocabs" add-startup-hook

: add-definition-observer ( obj -- )
    definition-observers get push ;

: remove-definition-observer ( obj -- )
    definition-observers get remove-eq! drop ;

: notify-definition-observers ( assoc -- )
    definition-observers get
    [ definitions-changed ] with each ;

! Incremented each time stack effects potentially changed, used
! by compiler.tree.propagation.call-effect for call( and execute(
! inline caching
: effect-counter ( -- n ) 47 special-object ; inline

GENERIC: always-bump-effect-counter? ( defspec -- ? )

M: object always-bump-effect-counter? drop f ;

<PRIVATE

: changed-vocabs ( assoc -- vocabs )
    [ drop word? ] assoc-filter
    [ drop vocabulary>> dup [ vocab ] when dup ] assoc-map ;

: updated-definitions ( -- assoc )
    H{ } clone
    dup forgotten-definitions get update
    dup new-definitions get first update
    dup new-definitions get second update
    dup changed-definitions get update
    dup changed-classes get update
    dup dup changed-vocabs update ;

: process-forgotten-definitions ( -- )
    forgotten-definitions get keys
    [ [ word? ] filter process-forgotten-words ]
    [ [ delete-definition-errors ] each ]
    bi ;

: bump-effect-counter? ( -- ? )
    changed-effects get
    changed-classes get
    changed-definitions get [ drop always-bump-effect-counter? ] assoc-filter
    3array assoc-combine new-words get assoc-diff assoc-empty? not ;

: bump-effect-counter ( -- )
    bump-effect-counter? [
        47 special-object 0 or
        1 +
        47 set-special-object
    ] when ;

: notify-observers ( -- )
    updated-definitions dup assoc-empty?
    [ drop ] [ notify-definition-observers notify-error-observers ] if ;

: finish-compilation-unit ( -- )
    [ ] [
        remake-generics
        to-recompile recompile
        update-tuples
        process-forgotten-definitions
        modify-code-heap
        bump-effect-counter
        notify-observers
    ] if-bootstrapping ;

PRIVATE>

: with-nested-compilation-unit ( quot -- )
    [
        H{ } clone changed-definitions set
        H{ } clone changed-classes set
        H{ } clone changed-effects set
        H{ } clone outdated-generics set
        H{ } clone outdated-tuples set
        H{ } clone new-words set
        [ finish-compilation-unit ] [ ] cleanup
    ] with-scope ; inline

: with-compilation-unit ( quot -- )
    [
        H{ } clone changed-definitions set
        H{ } clone changed-classes set
        H{ } clone changed-effects set
        H{ } clone outdated-generics set
        H{ } clone forgotten-definitions set
        H{ } clone outdated-tuples set
        H{ } clone new-words set
        <definitions> new-definitions set
        <definitions> old-definitions set
        [ finish-compilation-unit ] [ ] cleanup
    ] with-scope ; inline
