! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

IN: listener
USE: combinators
USE: continuations
USE: init
USE: interpreter
USE: kernel
USE: lists
USE: namespaces
USE: stack
USE: stdio
USE: styles
USE: streams
USE: strings
USE: unparser

: <attribute-set> ( -- attribute-set )
    [ ] "javax.swing.text.SimpleAttributeSet" jnew ;

: attribute+ ( attribute-set value key -- )
    transp
    [ "java.lang.Object" "java.lang.Object" ]
    "javax.swing.text.SimpleAttributeSet"
    "addAttribute" jinvoke ;

: style-constant ( name -- key )
    #! javax.swing.text.StyleConstants contains static variables
    #! which key in an AttributeSet.
    "javax.swing.text.StyleConstants" swap jvar-static-get
    ; inline

: set-icon-style ( attribute-set icon -- )
    [
        "javax.swing.text.MutableAttributeSet"
        "javax.swing.Icon"
    ] "javax.swing.text.StyleConstants"
    "setIcon" jinvoke-static ;

: <icon> ( resource -- icon )
    resource
    [ "java.net.URL" ]
    "javax.swing.ImageIcon" jnew ;

: swing-attribute+ ( attribute-set value key -- )
    style-constant attribute+ ;

: >color ( triplet -- hex )
    uncons uncons uncons drop
    [ "int" "int" "int" ]
    "java.awt.Color"
    jnew ;

: actions-key ( -- attr )
    "factor.listener.FactorListener" "Actions" jvar-static-get
    ; inline

: <action-menu-item> ( path pair -- pair )
    uncons >r " " swap cat3 r> cons ;

: <actions-menu> ( path actions -- alist )
    [ dupd <action-menu-item> ] map nip ;

: object-actions ( -- list )
    [
        [ "describe-path"  | "Describe" ]
        [ "lookup"         | "Push" ]
        [ "lookup execute" | "Execute" ]
        [ "lookup jedit"   | "jEdit" ]
        [ "lookup usages." | "Usages" ]
    ] ;

: <object-actions-menu> ( path -- alist )
    unparse object-actions <actions-menu> ;

: file-actions ( -- list )
    [
        [ ""               | "Push" ]
        [ "run-file"       | "Run file" ]
        [ "directory."     | "List directory" ]
    ] ;

: <file-actions-menu> ( path -- alist )
    unparse file-actions <actions-menu> ;

: underline-attribute ( attribute-set -- )
    t "Underline" swing-attribute+ ;

: object-link-attribute ( attribute-set target -- )
    over underline-attribute
    <object-actions-menu> actions-key attribute+ ;

: file-link-attribute ( attribute-set target -- )
    over underline-attribute
    <file-actions-menu> actions-key attribute+ ;

: style>attribute-set ( style -- attribute-set )
    <attribute-set> swap [
        [ "object-link" dupd object-link-attribute ]
        [ "file-link"   dupd file-link-attribute ]
        [ "bold"        drop dup t "Bold" swing-attribute+ ]
        [ "italics"     drop dup t "Italic" swing-attribute+ ]
        [ "underline"   drop dup t "Underline" swing-attribute+ ]
        [ "fg"          dupd >color "Foreground" swing-attribute+ ]
        [ "bg"          dupd >color "Background" swing-attribute+ ]
        [ "font"        dupd "FontFamily" swing-attribute+ ]
        [ "size"        dupd "FontSize" swing-attribute+ ]
        [ "icon"        dupd <icon> set-icon-style ]
    ] assoc-apply ;

: set-character-attrs ( attrs -- )
    t "listener" get
    [ "javax.swing.text.AttributeSet" "boolean" ]
    "javax.swing.JTextPane"
    "setCharacterAttributes"
    jinvoke ;

: set-paragraph-attrs ( attrs -- )
    t "listener" get
    [ "javax.swing.text.AttributeSet" "boolean" ]
    "javax.swing.JTextPane"
    "setCharacterAttributes"
    jinvoke ;

: reset-attrs ( -- )
    default-style style>attribute-set set-character-attrs ;

: listener-readln* ( continuation -- )
    "listener" get
	[ "factor.Cons" ]
	"factor.listener.FactorListener"
	"readLine" jinvoke ;

: listener-readln ( -- line )
    reset-attrs [ listener-readln* toplevel ] callcc1 ;

: listener-write-attr ( string style -- )
    style>attribute-set "listener" get
    [ "java.lang.String" "javax.swing.text.AttributeSet" ]
    "factor.listener.FactorListener"
    "insertWithAttrs"
    jinvoke ;

!: listener-edit ( string -- )
!    "listener" get
!    [ "java.lang.String" ]
!    "factor.listener.FactorListener"
!    "editLine" jinvoke ;

: <listener-stream> ( listener -- stream )
    #! Creates a stream for reading/writing to the given
    #! listener instance.
    <stream> [
        "listener" set
        ( -- string )
        [ listener-readln ] "freadln" set
        ( string -- )
        [ default-style listener-write-attr ] "fwrite" set
        ( string style -- )
        [ listener-write-attr ] "fwrite-attr" set
        ( string -- )
        ![ listener-edit ] "fedit" set
        ( -- )
        [ ] "fflush" set
        ( -- )
        [ ] "fclose" set
        ( string -- )
        [ this fwrite "\n" this fwrite ] "fprint" set
    ] extend ;

: new-listener-hook ( listener -- )
    #! Called when user opens a new listener
    [
        dup "listener" set
        <listener-stream> "stdio" set
        init-interpreter
    ] with-scope ;
