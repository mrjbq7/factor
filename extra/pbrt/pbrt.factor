! Copyright (C) 2026 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays ascii combinators
combinators.short-circuit combinators.smart io io.encodings.utf8
io.files io.streams.string kernel math math.parser namespaces
sequences sequences.generalizations splitting strings ;

IN: pbrt

TUPLE: pbrt-param type name values ;
TUPLE: pbrt-camera type params ;
TUPLE: pbrt-film type params ;
TUPLE: pbrt-sampler type params ;
TUPLE: pbrt-integrator type params ;
TUPLE: pbrt-accelerator type params ;
TUPLE: pbrt-pixel-filter type params ;
TUPLE: pbrt-shape type params ;
TUPLE: pbrt-material type params ;
TUPLE: pbrt-light-source type params ;
TUPLE: pbrt-area-light type params ;
TUPLE: pbrt-texture name value-type class params ;
TUPLE: pbrt-named-material name params ;
TUPLE: pbrt-use-material name ;
TUPLE: pbrt-make-named-medium name params ;
TUPLE: pbrt-medium-interface interior exterior ;
TUPLE: pbrt-world-begin ;
TUPLE: pbrt-world-end ;
TUPLE: pbrt-attribute-begin ;
TUPLE: pbrt-attribute-end ;
TUPLE: pbrt-transform-begin ;
TUPLE: pbrt-transform-end ;
TUPLE: pbrt-reverse-orientation ;
TUPLE: pbrt-identity ;
TUPLE: pbrt-translate x y z ;
TUPLE: pbrt-scale x y z ;
TUPLE: pbrt-rotate angle x y z ;
TUPLE: pbrt-look-at eye-x eye-y eye-z look-x look-y look-z up-x up-y up-z ;
TUPLE: pbrt-transform matrix ;
TUPLE: pbrt-concat-transform matrix ;
TUPLE: pbrt-coordinate-system name ;
TUPLE: pbrt-coord-sys-transform name ;
TUPLE: pbrt-include filename ;
TUPLE: pbrt-object-begin name ;
TUPLE: pbrt-object-end ;
TUPLE: pbrt-object-instance name ;

ERROR: pbrt-parse-error msg ;

<PRIVATE

SYMBOL: pbrt-pushback
SYMBOL: pbrt-token-pushback

: save-char ( ch -- )
    pbrt-pushback set ;

: get-pushback ( -- ch/f )
    pbrt-pushback [ f ] change ;

: pbrt-read1 ( -- ch/f )
    get-pushback [ read1 ] unless* ;

: skip-ws ( -- )
    pbrt-read1 {
        { [ dup not ] [ drop ] }
        { [ dup CHAR: # = ] [
            drop "\n" read-until 2drop skip-ws
        ] }
        { [ dup blank? ] [ drop skip-ws ] }
        [ save-char ]
    } cond ;

: read-quoted-string ( -- string )
    "\"" read-until drop ;

: digit-or-sign? ( ch -- ? )
    { [ digit? ] [ "-+." member? ] } 1|| ;

: number-char? ( ch -- ? )
    { [ digit? ] [ ".-+eE" member? ] } 1|| ;

: read-number-string ( first-char -- string )
    1string
    [ pbrt-read1 dup [ dup number-char? ] [ f ] if ]
    [ 1string append ] while [ save-char ] when* ;

: read-bare-word ( first-char -- string )
    1string
    [ pbrt-read1 dup [ dup Letter? ] [ f ] if ]
    [ 1string append ] while [ save-char ] when* ;

SINGLETON: open-bracket
SINGLETON: close-bracket

: read-token ( -- token/f )
    skip-ws pbrt-read1 {
        { [ dup not ] [ ] }
        { [ dup CHAR: " = ] [ drop read-quoted-string ] }
        { [ dup CHAR: [ = ] [ drop open-bracket ] }
        { [ dup CHAR: ] = ] [ drop close-bracket ] }
        { [ dup digit-or-sign? ] [
            read-number-string string>number
        ] }
        { [ dup Letter? ] [ read-bare-word ] }
        [ "Unexpected character" pbrt-parse-error ]
    } cond ;

: save-token ( token -- )
    pbrt-token-pushback set ;

: get-token-pushback ( -- token/f )
    pbrt-token-pushback [ f ] change ;

: next-token ( -- token/f )
    get-token-pushback [ read-token ] unless* ;

: parse-param-descriptor ( string -- type name )
    " " split1
    [ "Invalid parameter descriptor" pbrt-parse-error ]
    unless* ;

: read-bracketed-values ( -- values )
    [
        read-token
        [ dup close-bracket? not ]
        [ "Unexpected EOF in bracketed values" pbrt-parse-error ]
        if*
    ] [ ] produce nip ;

: read-param ( -- param/f )
    next-token {
        { [ dup not ] [ drop f ] }
        { [ dup string? ] [
            dup CHAR: \s swap member? [
                parse-param-descriptor next-token
                dup open-bracket? [
                    drop read-bracketed-values
                ] [
                    1array
                ] if
                pbrt-param boa
            ] [
                save-token f
            ] if
        ] }
        [ save-token f ]
    } cond ;

: read-params ( -- params )
    [ read-param dup ] [ ] produce nip ;

: read-typed-params ( -- type params )
    next-token read-params ;

: read-n-numbers ( n -- seq )
    [ next-token ] replicate ;

: read-directive ( keyword -- directive )
    {
        { "Camera" [ read-typed-params pbrt-camera boa ] }
        { "Film" [ read-typed-params pbrt-film boa ] }
        { "Sampler" [ read-typed-params pbrt-sampler boa ] }
        { "Integrator" [
            read-typed-params pbrt-integrator boa
        ] }
        { "Accelerator" [
            read-typed-params pbrt-accelerator boa
        ] }
        { "PixelFilter" [
            read-typed-params pbrt-pixel-filter boa
        ] }
        { "Shape" [ read-typed-params pbrt-shape boa ] }
        { "Material" [
            read-typed-params pbrt-material boa
        ] }
        { "LightSource" [
            read-typed-params pbrt-light-source boa
        ] }
        { "AreaLightSource" [
            read-typed-params pbrt-area-light boa
        ] }
        { "Texture" [
            next-token next-token next-token
            read-params pbrt-texture boa
        ] }
        { "MakeNamedMaterial" [
            next-token read-params pbrt-named-material boa
        ] }
        { "NamedMaterial" [
            next-token pbrt-use-material boa
        ] }
        { "MakeNamedMedium" [
            next-token read-params
            pbrt-make-named-medium boa
        ] }
        { "MediumInterface" [
            next-token next-token pbrt-medium-interface boa
        ] }
        { "WorldBegin" [ pbrt-world-begin boa ] }
        { "WorldEnd" [ pbrt-world-end boa ] }
        { "AttributeBegin" [
            pbrt-attribute-begin boa
        ] }
        { "AttributeEnd" [ pbrt-attribute-end boa ] }
        { "TransformBegin" [
            pbrt-transform-begin boa
        ] }
        { "TransformEnd" [ pbrt-transform-end boa ] }
        { "ReverseOrientation" [
            pbrt-reverse-orientation boa
        ] }
        { "Identity" [ pbrt-identity boa ] }
        { "Translate" [
            3 read-n-numbers first3 pbrt-translate boa
        ] }
        { "Scale" [
            3 read-n-numbers first3 pbrt-scale boa
        ] }
        { "Rotate" [
            4 read-n-numbers first4 pbrt-rotate boa
        ] }
        { "LookAt" [
            9 read-n-numbers
            9 firstn pbrt-look-at boa
        ] }
        { "Transform" [
            next-token open-bracket?
            [ "Expected [" pbrt-parse-error ] unless
            read-bracketed-values pbrt-transform boa
        ] }
        { "ConcatTransform" [
            next-token open-bracket?
            [ "Expected [" pbrt-parse-error ] unless
            read-bracketed-values
            pbrt-concat-transform boa
        ] }
        { "CoordinateSystem" [
            next-token pbrt-coordinate-system boa
        ] }
        { "CoordSysTransform" [
            next-token pbrt-coord-sys-transform boa
        ] }
        { "Include" [ next-token pbrt-include boa ] }
        { "ObjectBegin" [
            next-token pbrt-object-begin boa
        ] }
        { "ObjectEnd" [ pbrt-object-end boa ] }
        { "ObjectInstance" [
            next-token pbrt-object-instance boa
        ] }
        [ "Unknown directive: " prepend pbrt-parse-error ]
    } case ;

: read-directives ( -- directives )
    [ next-token dup ] [ read-directive ] produce nip ;

PRIVATE>

: read-pbrt ( -- directives )
    f pbrt-pushback set
    f pbrt-token-pushback set
    read-directives ;

GENERIC: pbrt> ( input -- directives )

M: string pbrt>
    [ read-pbrt ] with-string-reader ;

: path>pbrt ( path -- directives )
    utf8 [ read-pbrt ] with-file-reader ;

<PRIVATE

: write-quoted ( string -- )
    "\"" write write "\"" write ;

: write-number ( num -- )
    dup integer? [ number>string ] [
        dup >integer >float over =
        [ >integer number>string ] [ number>string ] if
    ] if write ;

: write-param ( param -- )
    " " write
    dup [ type>> ] [ name>> ] bi " " glue write-quoted
    " " write
    values>> dup length 1 = [
        first dup string?
        [ write-quoted ] [ write-number ] if
    ] [
        "[" write
        [
            " " write dup string?
            [ write-quoted ] [ write-number ] if
        ] each
        "]" write
    ] if ;

: write-params ( params -- )
    [ write-param ] each ;

: write-type-params ( type params word-string -- )
    write " " write
    [ write-quoted ] [ write-params ] bi* ;

: write-numbers ( seq -- )
    [ " " write write-number ] each ;

PRIVATE>

GENERIC: write-pbrt-directive ( directive -- )

M: pbrt-camera write-pbrt-directive
    [ type>> ] [ params>> ] bi "Camera" write-type-params ;

M: pbrt-film write-pbrt-directive
    [ type>> ] [ params>> ] bi "Film" write-type-params ;

M: pbrt-sampler write-pbrt-directive
    [ type>> ] [ params>> ] bi "Sampler" write-type-params ;

M: pbrt-integrator write-pbrt-directive
    [ type>> ] [ params>> ] bi "Integrator" write-type-params ;

M: pbrt-accelerator write-pbrt-directive
    [ type>> ] [ params>> ] bi "Accelerator" write-type-params ;

M: pbrt-pixel-filter write-pbrt-directive
    [ type>> ] [ params>> ] bi "PixelFilter" write-type-params ;

M: pbrt-shape write-pbrt-directive
    [ type>> ] [ params>> ] bi "Shape" write-type-params ;

M: pbrt-material write-pbrt-directive
    [ type>> ] [ params>> ] bi "Material" write-type-params ;

M: pbrt-light-source write-pbrt-directive
    [ type>> ] [ params>> ] bi "LightSource" write-type-params ;

M: pbrt-area-light write-pbrt-directive
    [ type>> ] [ params>> ] bi "AreaLightSource" write-type-params ;

M: pbrt-texture write-pbrt-directive
    {
        [ "Texture " write name>> write-quoted ]
        [ " " write value-type>> write-quoted ]
        [ " " write class>> write-quoted ]
        [ params>> write-params ]
    } cleave ;

M: pbrt-named-material write-pbrt-directive
    "MakeNamedMaterial" write
    [ " " write name>> write-quoted ]
    [ params>> write-params ] bi ;

M: pbrt-use-material write-pbrt-directive
    "NamedMaterial" write " " write name>> write-quoted ;

M: pbrt-make-named-medium write-pbrt-directive
    "MakeNamedMedium" write
    [ " " write name>> write-quoted ]
    [ params>> write-params ] bi ;

M: pbrt-medium-interface write-pbrt-directive
    "MediumInterface" write
    [ " " write interior>> write-quoted ]
    [ " " write exterior>> write-quoted ] bi ;

M: pbrt-world-begin write-pbrt-directive
    drop "WorldBegin" write ;

M: pbrt-world-end write-pbrt-directive
    drop "WorldEnd" write ;

M: pbrt-attribute-begin write-pbrt-directive
    drop "AttributeBegin" write ;

M: pbrt-attribute-end write-pbrt-directive
    drop "AttributeEnd" write ;

M: pbrt-transform-begin write-pbrt-directive
    drop "TransformBegin" write ;

M: pbrt-transform-end write-pbrt-directive
    drop "TransformEnd" write ;

M: pbrt-reverse-orientation write-pbrt-directive
    drop "ReverseOrientation" write ;

M: pbrt-identity write-pbrt-directive
    drop "Identity" write ;

M: pbrt-translate write-pbrt-directive
    "Translate" write
    { [ x>> ] [ y>> ] [ z>> ] } cleave>array
    write-numbers ;

M: pbrt-scale write-pbrt-directive
    "Scale" write
    { [ x>> ] [ y>> ] [ z>> ] } cleave>array
    write-numbers ;

M: pbrt-rotate write-pbrt-directive
    "Rotate" write {
        [ angle>> ] [ x>> ] [ y>> ] [ z>> ]
    } cleave>array write-numbers ;

M: pbrt-look-at write-pbrt-directive
    "LookAt" write {
        [ eye-x>> ] [ eye-y>> ] [ eye-z>> ]
        [ look-x>> ] [ look-y>> ] [ look-z>> ]
        [ up-x>> ] [ up-y>> ] [ up-z>> ]
    } cleave>array write-numbers ;

M: pbrt-transform write-pbrt-directive
    "Transform [" write matrix>> write-numbers " ]" write ;

M: pbrt-concat-transform write-pbrt-directive
    "ConcatTransform [" write matrix>> write-numbers " ]" write ;

M: pbrt-coordinate-system write-pbrt-directive
    "CoordinateSystem " write name>> write-quoted ;

M: pbrt-coord-sys-transform write-pbrt-directive
    "CoordSysTransform " write name>> write-quoted ;

M: pbrt-include write-pbrt-directive
    "Include " write filename>> write-quoted ;

M: pbrt-object-begin write-pbrt-directive
    "ObjectBegin " write name>> write-quoted ;

M: pbrt-object-end write-pbrt-directive
    drop "ObjectEnd" write ;

M: pbrt-object-instance write-pbrt-directive
    "ObjectInstance " write name>> write-quoted ;

: write-pbrt ( directives -- )
    [ write-pbrt-directive nl ] each ;

: >pbrt ( directives -- string )
    [ write-pbrt ] with-string-writer ;

: pbrt>path ( directives path -- )
    utf8 [ write-pbrt ] with-file-writer ;
