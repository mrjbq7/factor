! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words words.symbol sequences vocabs kernel
compiler.units ;
IN: bootstrap.syntax

[
    "syntax" create-vocab drop

    {
        "!"
        "\""
        "#!"
        "("
        "(("
        ":"
        ";"
        "<PRIVATE"
        "BIN:"
        "B{"
        "BV{"
        "C:"
        "CHAR:"
        "DEFER:"
        "ERROR:"
        "FORGET:"
        "GENERIC#"
        "GENERIC:"
        "HEX:"
        "HOOK:"
        "H{"
        "HS{"
        "IN:"
        "INSTANCE:"
        "M:"
        "MAIN:"
        "MATH:"
        "MIXIN:"
        "NAN:"
        "OCT:"
        "P\""
        "POSTPONE:"
        "PREDICATE:"
        "PRIMITIVE:"
        "PRIVATE>"
        "SBUF\""
        "SINGLETON:"
        "SINGLETONS:"
        "SYMBOL:"
        "SYMBOLS:"
        "CONSTANT:"
        "TUPLE:"
        "final"
        "SLOT:"
        "T{"
        "UNION:"
        "INTERSECTION:"
        "USE:"
        "UNUSE:"
        "USING:"
        "QUALIFIED:"
        "QUALIFIED-WITH:"
        "FROM:"
        "EXCLUDE:"
        "RENAME:"
        "ALIAS:"
        "SYNTAX:"
        "V{"
        "W{"
        "["
        "\\"
        "M\\"
        "]"
        "delimiter"
        "deprecated"
        "f"
        "flushable"
        "foldable"
        "inline"
        "recursive"
        "t"
        "{"
        "}"
        "CS{"
        "<<"
        ">>"
        "call-next-method"
        "initial:"
        "read-only"
        "call("
        "execute("
        "<<<<<<"
        "======"
        ">>>>>>"
        "<<<<<<<"
        "======="
        ">>>>>>>"
    } [ "syntax" create drop ] each

    "t" "syntax" lookup define-symbol
] with-compilation-unit
