using BasedDumps, Test

const tstr = b"Julia has good support for interactive use 😀."
const utf16 = vcat(b"\xff\xfe", reinterpret(UInt8, transcode(UInt16, tstr)))
print("hexdump of utf-16 string "), display(String(tstr))
hexdump(utf16)
print("\nxxd of utf-16 string "), display(String(tstr))
xxd(utf16)
print("\ndecdump of utf-16 string "), display(String(tstr))
decdump(utf16)
