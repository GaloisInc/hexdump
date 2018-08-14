module Hexdump (prettyHex, simpleHex) where

import           Data.ByteString       (ByteString)
import qualified Data.ByteString       as B (length, unpack)
import qualified Data.ByteString.Char8 as B8 (unpack)
import           Data.Char             (isAscii, isControl)
import           Data.List             (intercalate, transpose, unfoldr)
import           Numeric               (showHex)

byteWidth    = 2  -- Width of an padded 'Word8'
numWordBytes = 4  -- Number of bytes to group into a 32-bit word

-- |'prettyHex' renders a 'ByteString' as a multi-line 'String' complete with
-- addressing, hex digits, and ASCII representation.
--
-- Sample output
--
--            +----------------------------------------------------+
--            |  0  1  2  3  4   5  6  7  8  9  a  b   c  d  e  f  |
-- +----------+----------------------------------------------------+------------------+
-- | 00000000 | 4b c1 ad 8a  5b 47 d7 57  48 64 e7 cc  5e b5 2f 6e | K...[G.WHd..^./n |
-- | 00000010 | c5 b3 a4 73  44 3b 97 53  99 2d 54 e7  1b 2f 91 12 | ...sD;.S.-T../.. |
-- | 00000020 | c8 1a ff c4  3b 2b 72 ea  97 e2 9f e2  93 ad 23 79 | ....;+r.......#y |
-- | 00000030 | e8 0f 08 54  02 14 fa 09  f0 2d 34 c9  08 6b e1 64 | ...T.....-4..k.d |
-- | 00000040 | d1 c5 98 7e  d6 a1 98 e2  97 da 46 68  4e 60 11 15 | ...~......FhN`.. |
-- | 00000050 | d8 32 c6 0b  70 f5 2e 76  7f 8d f2 3b  ed de 90 c6 | .2..p..v...;.... |
-- | 00000060 | 93 12 9c e1                                        | ....@            |
-- +----------+----------------------------------------------------+------------------+
--  @Length: 100 (0x64) bytes

-- Calculated width of the hex display panel
hexDisplayWidth :: Int
hexDisplayWidth = 50

-- Number of words to group onto a line
numLineWords :: Int
numLineWords = 4

-- Minimum width of a padded address
addressWidth :: Int
addressWidth = 8

-- Number of bytes on a line
numLineBytes :: Int
numLineBytes = numLineWords * numWordBytes

-- 'Char' to use for non-printable characters
replacementChar :: Char
replacementChar = '.'

border :: String
border =
  concat [
    '+' : replicate (addressWidth + 2) '-'
    , '+' : replicate (hexDisplayWidth + 2) '-'
    , '+' : replicate (numLineBytes + 2) '-'
    , ['+']
  ]

header :: [String]
header =
  [ concat [
      replicate (addressWidth + 3) ' '
      , '+' : replicate (hexDisplayWidth + 2) '-'
      , ['+']
    ]
  , concat [
      replicate (addressWidth + 3) ' '
      , '|' : "  0  1  2  3   4  5  6  7  8  9  a  b   c  d  e  f  "
      , '|' : replicate (numLineBytes + 2) ' '
    ]
  , border
  ]

prettyHex :: ByteString -> String
prettyHex bs = (unlines . concat) [ header, body, footer ]
 where
  footer = [
      border
    , concat [ " Length: ", show (B.length bs), " (0x", showHex (B.length bs) ") bytes" ]
    ]

  body = map ((\x -> concat [ "| ", x, " |"]) . intercalate " | ")
       $ transpose [mkLineNumbers bs, mkHexDisplay bs, mkAsciiDump bs]

  mkHexDisplay
    = padLast hexDisplayWidth
    . map (intercalate "  ") . group numLineWords
    . map unwords  . group numWordBytes
    . map (paddedShowHex byteWidth)
    . B.unpack

  mkAsciiDump = padLast numLineBytes . group numLineBytes . cleanString . B8.unpack

  cleanString = map go
   where
    go x | isWorthPrinting x = x
         | otherwise         = replacementChar

  mkLineNumbers bs = [paddedShowHex addressWidth (x * numLineBytes)
                     | x <- [0 .. (B.length bs - 1) `div` numLineBytes] ]

  padLast w [x]    = [x ++ replicate (w - length x) ' ']
  padLast w (x:xs) = x : padLast w xs
  padLast _ []     = []

-- |'paddedShowHex' displays a number in hexidecimal and pads the number
-- with 0 so that it has a minimum length of @w@.
paddedShowHex :: (Show a, Integral a) => Int -> a -> String
paddedShowHex w n = pad ++ str
    where
     str = showHex n ""
     pad = replicate (w - length str) '0'


-- |'simpleHex' converts a 'ByteString' to a 'String' showing the octets
-- grouped in 32-bit words.
--
-- Sample output
--
-- @4b c1 ad 8a  5b 47 d7 57@
simpleHex :: ByteString -> String
simpleHex = intercalate "  "
          . map (intercalate " ") . group numWordBytes
          . map (paddedShowHex byteWidth)
          . B.unpack

-- |'isWorthPrinting' returns 'True' for non-control ascii characters.
-- These characters will all fit in a single character when rendered.
isWorthPrinting :: Char -> Bool
isWorthPrinting x = isAscii x && not (isControl x)

-- |'group' breaks up a list into sublists of size @n@. The last group
-- may be smaller than @n@ elements. When @n@ less not positive the
-- list is returned as one sublist.
group :: Int -> [a] -> [[a]]
group n
 | n <= 0    = (:[])
 | otherwise = unfoldr go
  where
    go [] = Nothing
    go xs = Just (splitAt n xs)

