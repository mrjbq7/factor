! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences assocs math kernel accessors fry
combinators combinators.short-circuit sets locals columns grouping
stack-checker.branches
compiler.tree
compiler.tree.def-use
compiler.tree.combinators
compiler.utilities ;
IN: compiler.tree.propagation.copy

! Two values are copy-equivalent if they are always identical
! at run-time ("DS" relation). This is just a weak form of
! value numbering.

! Mapping from values to their canonical leader
SYMBOL: copies

: resolve-copy ( copy -- val ) copies get compress-path ;

: is-copy-of ( val copy -- ) copies get set-at ;

: are-copies-of ( vals copies -- ) copies get [ set-at ] curry 2each ;

: introduce-values ( vals -- ) copies get [ conjoin ] curry each ;

GENERIC: compute-copy-equiv* ( node -- )

M: #renaming compute-copy-equiv* inputs/outputs are-copies-of ;

: compute-phi-equiv ( inputs outputs -- )
    #! An output is a copy of every input if all inputs are
    #! copies of the same original value.
    [
        swap remove-bottom [ resolve-copy ] map!
        dup { [ empty? not ] [ all-equal? ] } 1&&
        [ first swap is-copy-of ] [ 2drop ] if
    ] 2each ;

M: #phi compute-copy-equiv*
    [ phi-in-d>> flip ] [ out-d>> ] bi compute-phi-equiv ;

M: node compute-copy-equiv* drop ;

: compute-copy-equiv ( node -- )
    [ node-defs-values introduce-values ]
    [ compute-copy-equiv* ]
    bi ;
