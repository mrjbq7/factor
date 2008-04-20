! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences vocabs kernel ;
IN: bootstrap.syntax

"syntax" create-vocab drop

{
    "!"
    "\""
    "#!"
    "("
    ":"
    ";"
    "<PRIVATE"
    "?{"
    "BIN:"
    "B{"
    "C:"
    "CHAR:"
    "DEFER:"
    "ERROR:"
    "F{"
    "FORGET:"
    "GENERIC#"
    "GENERIC:"
    "HEX:"
    "HOOK:"
    "H{"
    "IN:"
    "INSTANCE:"
    "M:"
    "MAIN:"
    "MATH:"
    "MIXIN:"
    "OCT:"
    "P\""
    "POSTPONE:"
    "PREDICATE:"
    "PRIMITIVE:"
    "PRIVATE>"
    "SBUF\""
    "SINGLETON:"
    "SYMBOL:"
    "TUPLE:"
    "T{"
    "UNION:"
    "USE:"
    "USING:"
    "V{"
    "W{"
    "["
    "\\"
    "]"
    "delimiter"
    "f"
    "flushable"
    "foldable"
    "inline"
    "parsing"
    "t"
    "{"
    "}"
    "CS{"
    "<<"
    ">>"
    "call-next-method"
} [ "syntax" create drop ] each

"t" "syntax" lookup define-symbol
