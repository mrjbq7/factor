! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: lists USING: errors generic kernel math sequences ;

! Sequence protocol
M: general-list length 0 swap [ drop 1 + ] each ;

M: f nth "List index out of bounds" throw ;

M: cons nth ( n list -- element )
    >r dup 0 = [
        drop r> car
    ] [
        1 - r> cdr nth
    ] ifte ;

M: f empty? drop t ;
M: cons empty? drop f ;

: 2list ( a b -- [ a b ] )
    unit cons ;

: 2unlist ( [ a b ] -- a b )
    uncons car ;

: 3list ( a b c -- [ a b c ] )
    2list cons ;

: 3unlist ( [ a b c ] -- a b c )
    uncons uncons car ;

: contains? ( obj list -- ? )
    #! Test if a list contains an element equal to an object.
    [ = ] some-with? >boolean ;

: memq? ( obj list -- ? )
    #! Test if a list contains an object.
    [ eq? ] some-with? >boolean ;

: partition-add ( obj ? ret1 ret2 -- ret1 ret2 )
    rot [ swapd cons ] [ >r cons r> ] ifte ;

: partition-step ( ref list combinator -- ref cdr combinator car ? )
    pick pick car pick call >r >r unswons r> swap r> ; inline

: (partition) ( ref list combinator ret1 ret2 -- ret1 ret2 )
    >r >r  over [
        partition-step  r> r> partition-add  (partition)
    ] [
        3drop  r> r>
    ] ifte ; inline

: partition ( ref list combinator -- list1 list2 )
    #! The combinator must have stack effect:
    #! ( ref element -- ? )
    [ ] [ ] (partition) ; inline

: sort ( list comparator -- sorted )
    #! To sort in ascending order, comparator must have stack
    #! effect ( x y -- x>y ).
    over [
        ( Partition ) [ >r uncons dupd r> partition ] keep
        ( Recurse ) [ sort swap ] keep sort
        ( Combine ) swapd cons append
    ] [
        drop
    ] ifte ; inline

: unique ( elem list -- list )
    #! Prepend an element to a list if it does not occur in the
    #! list.
    2dup contains? [ nip ] [ cons ] ifte ;

M: general-list reverse ( list -- list )
    [ ] swap [ swons ] each ;

: map ( list quot -- list )
    #! Push each element of a proper list in turn, and collect
    #! return values of applying a quotation with effect
    #! ( X -- Y ) to each element into a new list.
    over [ (each) rot >r map r> swons ] [ drop ] ifte ; inline

: map-with ( obj list quot -- list )
    #! Push each element of a proper list in turn, and collect
    #! return values of applying a quotation with effect
    #! ( obj elt -- obj ) to each element into a new list.
    swap [ with rot ] map 2nip ; inline

: remove ( obj list -- list )
    #! Remove all occurrences of objects equal to this one from
    #! the list.
    [ = not ] subset-with ;

: remq ( obj list -- list )
    #! Remove all occurrences of the object from the list.
    [ eq? not ] subset-with ;

: prune ( list -- list )
    #! Remove duplicate elements.
    dup [ uncons prune unique ] when ;

: all=? ( list -- ? )
    #! Check if all elements of a list are equal.
    [ uncons [ = ] all-with? ] [ t ] ifte* ;

M: cons = ( obj cons -- ? )
    2dup eq? [
        2drop t
    ] [
        over cons? [
            2dup 2car = >r 2cdr = r> and
        ] [
            2drop f
        ] ifte
    ] ifte ;

M: f = ( obj f -- ? ) eq? ;

M: cons hashcode ( cons -- hash ) car hashcode ;

: (count) ( i n -- list )
    2dup >= [ 2drop [ ] ] [ >r dup 1 + r> (count) cons ] ifte ;

: count ( n -- [ 0 ... n-1 ] )
    0 swap (count) ;

: project ( n quot -- list )
    >r count r> map ; inline

: project-with ( elt n quot -- list )
    swap [ with rot ] project 2nip ; inline

: head ( list n -- list )
    #! Return the first n elements of the list.
    dup 0 > [ >r uncons r> 1 - head cons ] [ 2drop f ] ifte ;

: tail ( list n -- tail )
    #! Return the rest of the list, from the nth index onward.
    [ cdr ] times ;

: intersection ( list list -- list )
    #! Make a list of elements that occur in both lists.
    [ over contains? ] subset nip ;

: difference ( list1 list2 -- list )
    #! Make a list of elements that occur in list2 but not
    #! list1.
    [ over contains? not ] subset nip ;

: contained? ( list1 list2 -- ? )
    #! Is every element of list1 in list2?
    swap [ swap contains? ] all-with? ;

: <queue> ( -- queue )
    #! Make a new functional queue.
    [[ [ ] [ ] ]] ;

: queue-empty? ( queue -- ? )
    uncons or not ;

: enque ( obj queue -- queue )
    uncons >r cons r> cons ;

: deque ( queue -- obj queue )
    uncons [
        uncons swapd cons
    ] [
        reverse uncons f swons
    ] ifte* ;
