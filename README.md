# BasedDumps.jl
Binary file dumpers in base 16, 10 and 2 formats



##    function baseddump

    5 methods.

### function baseddump(io::IO, data::Vector{UInt8}, base = 16; offset = 0, len = -1)
### function baseddump(io::IO, data::Array, base = 16; offset = 0, len = -1)
### function baseddump(data, base = 16; offset = 0, len = -1)

    Print (to stdout, or if specified io) a dump of `data` as bytes. The portion
    dumped defaults to all of data, or else, if specified, from `offset` to `len`.
    The `base` used to print the data is between 16 (default) and 2 (binary).
    The data is formatted similar to the format of the unix utilities `hexdump` or
    `xxd` for bases 16 and 2, the decimal format for `base` 10 is similar to unix
    `hexdump` but with decimal format and similarly for base 8 and octal format.
    Any base between 2 and 16 is supported, but there are shorter function names 
    for base 2 (binary), base 8 (octal), base 10 (decimal), and the default 16
    (hexadecimal).

### function baseddump(to::IO, from::IO, base = 16; offset = 0, len = -1)
### function baseddump(to::IO, filename::AbstractString, base = 16; offset = 0, len = -1)

    Print (to stdout, or if specified to the IO `to`) a dump of the stream `from` or file
    `filename` as bytes. The portion dumped defaults to all of the data until eof(), 
    or else, if specified, from `offset` to `len`.

Note that these functions have shorter versions `hexdump` which defaults to base 16,
`xxd` which defaults to base 2, and `decdump` which defaults to base 10. 

#### Examples:

    hexdump("test.so") will dump the contents of file "test.so" as a hex display to stdout.

    xxd(stderr, s, offset = 16, length = 1008) will dump the bytes in s[16:16+1008-1], where s 
    is a vector of bytes, to stderr in a binary format.
    

### textdump(io::IO, txt::AbstractString, base::Integer; off = 0, len = -1)

    Dump (with `baseddump`) the string `txt`. Julia strings and utf-8 text
    will be interpreted as vectors of UInt8 corresponding to their bytes, and
    utf-16 text will retain its 16-bit character as little endian text, so
    ASCII chars within the utf-16 text will be displayed with a following 0
    byte in data displayed, and two-byte utf-8 chars with be displayed as two
    bytes, in lower byte then upper byte order.

###  textdump(txt, base; offset = 0, len = -1)

    This method is the same as the previous method of that name, but dumps only to stdout.
    
