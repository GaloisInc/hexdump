# hexdump
A human readable style for binary data.

Documentation may be found on Hackage: https://hackage.haskell.org/package/pretty-hex-1.0

This library generates pretty hex dumps of ByteStrings in the style of other common *nix hex dump tools.

For example:
```
 @Length: 100 (0x64) bytes
0000:   4b c1 ad 8a  5b 47 d7 57  48 64 e7 cc  5e b5 2f 6e   K...[G.WHd..^./n
0010:   c5 b3 a4 73  44 3b 97 53  99 2d 54 e7  1b 2f 91 12   ...sD;.S.-T../..
0020:   c8 1a ff c4  3b 2b 72 ea  97 e2 9f e2  93 ad 23 79   ....;+r.......#y
0030:   e8 0f 08 54  02 14 fa 09  f0 2d 34 c9  08 6b e1 64   ...T.....-4..k.d
0040:   d1 c5 98 7e  d6 a1 98 e2  97 da 46 68  4e 60 11 15   ...~......FhN`..
0050:   d8 32 c6 0b  70 f5 2e 76  7f 8d f2 3b  ed de 90 c6   .2..p..v...;....
0060:   93 12 9c e1                                          ....@
```
