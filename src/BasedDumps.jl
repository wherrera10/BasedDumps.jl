module BasedDumps

export baseddump, hexdump, xxd, decdump

"""
    function baseddump(io::IO, data, base = 16; offset = 0, len = -1)
    function baseddump(data, base = 16; offset = 0, len = -1)

    Print (to stdout, or if specified io) a dump of `data` as bytes. The portion
    dumped defaults to all of data, or else, if specified, from `offset` to `len`.
    The `base` used to print the data is one of 16 (default), 10, or 2 (binary).

    The data is formatted according to the unix utilities `hexdump` or `xxd`
    for bases 16 and 2, and is similar to `hexdump` for base 10.
"""
function baseddump(io::IO, data, base = 16; offset = 0, len = -1)
	@assert base in [2, 10, 16] "display base $base not supported"
	len = len < 0 ? length(data) : min(len, length(data))
	bytes = data[begin+offset:len]
	fullchunksize = base == 16 ? 16 : base == 10 ? 10 : 6
	halflen, pos, vlen = fullchunksize ÷ 2, 0, base == 16 ? 49 : base == 10 ? 41 : 55
	for chunk in Iterators.partition(bytes, fullchunksize)
		chunklen = length(chunk)
		values = map(n -> string(n, base = base,
				pad = base == 16 ? 2 : base == 10 ? 3 : 8) * " ", chunk)
		vstr = join(values[begin:begin+min(halflen, chunklen)-1])
		if chunklen > halflen
			vstr *= " "^(base != 2) * join(values[begin+halflen:end])
		end
		cstr = prod(map(n -> n < 128 && isprint(Char(n)) ? Char(n) : '.', chunk))
		println(io, string(pos, base = 16, pad = 8) * " " * rpad(vstr, vlen) * "|" * cstr * "|")
		pos += chunklen
	end
    println(io, string(pos, base=16, pad = 8))
end
baseddump(data, base = 16; offset = 0, len = -1) = baseddump(stdout, data, base; offset, len)

""" Get data from a stream `from` rather than a vector of data in memory. 
    NB: if offset is not 0, the IO must be seekable or will likely error.
"""
function baseddump(to::IO, from::IO, base = 16; offset = 0, len = -1)
    flen = stat(io).length
    len = len < 0 ? flen - offset : min(len, flen - offset)
    offset != 0 && seek(from, offset)
	data = read(io, len)
    baseddump(io::IO, data, base)
end

""" Get data from a file named `filename` rather than a vector in memory. """
function baseddump(to::IO, filename::AbstractString, base = 16; offset = 0, len = -1)
    fromio = open(filename)
    return baseddump(to::IO, fromio, base; offset, len)
end

""" Get data from a file `filename` rather than a vector of data in memory. """
function baseddump(to::IO, filename::AbstractString, base = 16; offset = 0, len = -1)
    io = open(filename)
    flen = stat(io).length
    len = len < 0 ? flen - offset : min(len, flen - offset)
    seek(from, offset)
	data = read(io, len)
    baseddump(io::IO, data, base)
end

""" dump hex """
hexdump(io::IO, data; offset = 0, len = -1) = baseddump(io, data; offset, len)
hexdump(data; offset = 0, len = -1) = baseddump(data; offset, len)
hexdump(filename::AbstractString; off = 0, len = -1) = hexdump(stdout, filename; off, len)

""" dump binary """
xxd(io::IO, data; offset = 0, len = -1) = baseddump(io, data, 2; offset, len)
xxd(data; offset = 0, len = -1) = baseddump(data, 2; offset, len)
xxd(filename::AbstractString; off = 0, len = -1) = baseddump(stdout, filename, 2; off, len)

""" dump decimal """
decdump(io::IO, data; offset = 0, len = -1) = baseddump(io, data, 10; offset, len)
decdump(data; offset = 0, len = -1) = baseddump(data, 10; offset, len)
decdump(filename::AbstractString; off = 0, len = -1) = baseddump(stdout, filename, 10; off, len)

end # module
