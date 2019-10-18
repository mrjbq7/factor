! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: inference
USE: interpreter
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: words
USE: vectors

! We build a dataflow graph for the compiler.
SYMBOL: dataflow-graph

! Label nodes have the node-label variable set.
SYMBOL: #label

! A label that is not called recursively at all, or only tail
! recursively. The optimizer changes some #labels to
! #simple-labels.
SYMBOL: #simple-label

SYMBOL: #call ( non-tail call )
SYMBOL: #call-label
SYMBOL: #push ( literal )

SYMBOL: #ifte
SYMBOL: #dispatch

! This is purely a marker for values we retain after a
! conditional. It does not generate code, but merely alerts the
! dataflow optimizer to the fact these values must be retained.
SYMBOL: #values

SYMBOL: #return

SYMBOL: #drop
SYMBOL: #dup
SYMBOL: #swap
SYMBOL: #over
SYMBOL: #pick

SYMBOL: #>r
SYMBOL: #r>

SYMBOL: #slot
SYMBOL: #set-slot

SYMBOL: node-consume-d
SYMBOL: node-produce-d
SYMBOL: node-consume-r
SYMBOL: node-produce-r
SYMBOL: node-op
SYMBOL: node-label

! #push nodes have this field set to the value being pushed.
! #call nodes have this as the word being called
SYMBOL: node-param

: <dataflow-node> ( param op -- node )
    <namespace> [
        node-op set
        node-param set
        [ ] node-consume-d set
        [ ] node-produce-d set
        [ ] node-consume-r set
        [ ] node-produce-r set
    ] extend ;

: node-inputs ( d-count r-count -- )
    #! Execute in the node's namespace.
    meta-r get vector-tail* node-consume-r set
    meta-d get vector-tail* node-consume-d set ;

: dataflow-inputs ( in node -- )
    [ length 0 node-inputs ] bind ;

: node-outputs ( d-count r-count -- )
    #! Execute in the node's namespace.
    meta-r get vector-tail* node-produce-r set
    meta-d get vector-tail* node-produce-d set ;

: dataflow-outputs ( out node -- )
    [ length 0 node-outputs ] bind ;

: get-dataflow ( -- IR )
    dataflow-graph get reverse ;

: dataflow, ( param op -- node )
    #! Add a node to the dataflow IR.
    <dataflow-node> dup dataflow-graph cons@ ;

: dataflow-drop, ( -- )
    #! Remove the top stack element and add a dataflow node
    #! noting this.
    f #drop dataflow, [ 1 0 node-inputs ] bind ;

: apply-dataflow ( dataflow name default -- )
    #! For the dataflow node, look up named word property,
    #! if its not defined, apply default quotation to
    #! ( node ) otherwise apply property quotation to
    #! ( node ).
    >r >r dup [ node-op get ] bind r> word-property dup [
        call r> drop
    ] [
        drop r> call
    ] ifte ;
