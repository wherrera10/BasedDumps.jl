using BasedDumps
using Test, Suppressor

const tstr = b"Julia has good support for interactive use 😀."
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
