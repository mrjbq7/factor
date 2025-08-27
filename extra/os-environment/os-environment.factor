! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs checksums checksums.openssl environment
io.directories io.files.info math.parser sequences splitting ;
IN: os-environment

: binaries ( -- assoc )
    "PATH" os-env
    ":" split [
        qualified-directory-files
        [ file-executable? ] filter
        [ directory? ] reject
    ] { } map-as concat
    [ openssl-sha256 checksum-file bytes>hex-string ] zip-with ;

