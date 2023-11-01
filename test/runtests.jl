using BasedDumps
using Test, Suppressor

const tstr = b"Julia has good support for interactive use 😀."
const str = "Julia has good support for interactive use 😀."
const utf16 = vcat(b"\xff\xfe", reinterpret(UInt8, transcode(UInt16, tstr)))
result = @capture_out hexdump(utf16)
@test contains(result, "u.s.e. .=.")
@test contains(result, "0000005e")
result = @capture_out xxd(utf16)
@test contains(result, "00111101 11011000")
result = @capture_out decdump(utf16)
@test contains(result, "100 000 | .g.o.o.d.")
result = @capture_out textdump(String(tstr))
@test contains(result, "6f 72 20 69 6e")

fname = tempname()
open(fname, "w") do fd; write(fd, str) end
result = @capture_out baseddump(fname, offset = 16)
@test contains(result, "6f 72 20 69 6e")

for base in 2:16
    bresult = @capture_out baseddump(stdout, collect(tstr); base, offset = base * 2)
    @test contains(bresult, ".|")
    bresult = @capture_out textdump(stdout, str; base, offset = base * 2)
    @test contains(bresult, ".|")
end
