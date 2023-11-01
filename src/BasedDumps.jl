module BasedDumps

export baseddump, hexdump, xxd, decdump, textdump

"""
    function baseddump

    5 methods.

function baseddump(io::IO, data::Vector{UInt8}; base = 16, offset = 0, len = -1)
function baseddump(io::IO, data::Array; base = 16, offset = 0, len = -1)
function baseddump(data; base = 16, offset = 0, len = -1)

    Print (to stdout, or if specified io) a dump of `data` as bytes. The portion
    dumped defaults to all of data, or else, if specified, from `offset` to `len`.
    The `base` used to print the data is between 16 (default) and 2 (binary).
    The data is formatted similar to the format of the unix utilities `hexdump` or
    `xxd` for bases 16 and 2, the decimal format for `base` 10 is similar to unix
    `hexdump` but with decimal format and similarly for base 8 and octal format.
    Any base between 2 and 16 is supported, but there are shorter function names
    for base 2 (binary), base 8 (octal), base 10 (decimal), and the default 16
    (hexadecimal).

function baseddump(to::IO, from::IO; base = 16, offset = 0, len = -1)
function baseddump(to::IO, filename::AbstractString; base = 16; offset = 0, len = -1)

    Print (to stdout, or if specified to the IO `to`) a dump of the stream `from` or file
    `filename` as bytes. The portion dumped defaults to all of the data until eof(),
    or else, if specified, from `offset` to `len`.

Note that these functions have shorter versions `hexdump` which defaults to base 16,
`xxd` which defaults to base 2, and `decdump` which defaults to base 10.

Examples:

    hexdump("test.so") will dump the contents of file "test.so" as a hex display to stdout.

    xxd(stderr, s, offset = 16, length = 1008) will dump the bytes in s[16:16+1008-1], where s
    is a vector of bytes, to stderr in a binary format.

"""
function baseddump(io::IO, data::Vector{UInt8}; base = 16, offset = 0, len = -1)
    @assert 2 <= base <= 16 "display base $base not supported"
    len = len < 0 ? length(data) : min(len, length(data))
    bytes = data[begin+offset:len]
    fullchunksize = base == 16 ? 16 : base > 8 ? 10 : base > 4 ? 8 : 6
    padsize = base == 16 ? 2 : base == 2 ? 8 : base > 7 ? 3 : base > 3 ? 4 : 5
    midpad = " "^(base != 2)
    vl = (padsize + 1) * fullchunksize + length(midpad)
    halflen, pos = fullchunksize ÷ 2, 0
    for chunk in Iterators.partition(bytes, fullchunksize)
        chunklen = length(chunk)
        values = map(n -> string(n, base = base, pad = padsize) * " ", chunk)
        s1 = join(values[begin:begin+min(halflen, chunklen)-1])
        if chunklen > halflen
            s1 *= midpad * join(values[begin+halflen:end])
        end
        s2 = prod(map(n -> n < 128 && isprint(Char(n)) ? Char(n) : '.', chunk))
        println(io, string(pos, base = 16, pad = 8) * " " * rpad(s1, vl) * "|" * s2 * "|")
        pos += chunklen
    end
    println(io, string(pos, base = 16, pad = 8))
end
function baseddump(io::IO, data::Array; base = 16, offset = 0, len = -1)
    bytevec::Vector{UInt8} = UInt8.(transcode(UInt8, data))
    return baseddump(io, bytevec; base, offset, len)
end
baseddump(data; base = 16, offset = 0, len = -1) = baseddump(stdout, data; base, offset, len)

""" Get data from a stream `from` rather than a vector of data in memory.
    NB: if offset is not 0, the IO must be seekable or will likely error.
"""
function baseddump(to::IO, from::IO; base = 16, offset = 0, len = -1)
    flen = stat(from).length
    len = len < 0 ? flen - offset : min(len, flen - offset)
    offset != 0 && seek(from, offset)
    data::Vector{UInt8} = read(from, len)
    baseddump(io::IO, data; base)
end

""" Get data from a file named `filename` rather than a vector in memory. """
function baseddump(to::IO, filename::AbstractString; base = 16, offset = 0, len = -1)
    fromio = open(filename)
    return baseddump(to, fromio; base, offset, len)
end

""" dump hex """
hexdump(io::IO, data; offset = 0, len = -1) = baseddump(io, data; offset, len)
hexdump(data; offset = 0, len = -1) = baseddump(data; offset, len)
hexdump(filename::AbstractString; off = 0, len = -1) = hexdump(stdout, filename; off, len)

""" dump binary """
xxd(io::IO, data; offset = 0, len = -1) = baseddump(io, data; base = 2, offset, len)
xxd(data; offset = 0, len = -1) = baseddump(data; base = 2, offset, len)
xxd(filename::AbstractString; off = 0, len = -1) = baseddump(stdout, filename; base = 2, off, len)

""" dump decimal """
decdump(io::IO, data; offset = 0, len = -1) = baseddump(io, data; base = 10, offset, len)
decdump(data; offset = 0, len = -1) = baseddump(data; base = 10, offset, len)
decdump(filename::AbstractString; offset = 0, len = -1) = baseddump(stdout, filename; base = 10, offset, len)

""" dump octal """
octdump(io::IO, data; offset = 0, len = -1) = baseddump(io, data, base = 8, offset, len)
octdump(data; offset = 0, len = -1) = baseddump(data; base = 8, offset, len)
octdump(filename::AbstractString; offset = 0, len = -1) = baseddump(stdout, filename; base = 8, offset, len)

"""
    textdump(io::IO, txt::AbstractString, base::Integer; offset = 0, len = -1)

Dump (with `baseddump`) the string `txt`. Julia strings will be interpreted
as utf-8 text, with mulitbyte chars displayed in little endian order.

    textdump(txt, base; offset = 0, len = -1)

This method is the same as the former one but dumps only to stdout.
"""
function textdump(io::IO, txt::AbstractString; base = 16, offset = 0, len = -1)
    data::Vector{UInt8} = UInt8.(transcode(UInt8, txt))
    return baseddump(io, data; base, offset, len)
end
textdump(txt; base = 16, offset = 0, len = -1) = textdump(stdout, txt; base, offset, len)

end # module
