-----------------------------------------------------------------------------
-- | Helper functions to format output for 'bar'
-----------------------------------------------------------------------------

module Bar (
           Alignment(..)
           , ColorControl(..)
           , clickable
           , reverseColors
           , align
           , changeColor
           , clickable2
           ) where

data Alignment    = ALeft | ACenter | ARight
data ColorControl = F | B deriving (Show)

clickable :: String -> String -> String
clickable script text = "%{A:" ++ script ++ ":}" ++ text ++ "%{A}"

reverseColors :: String -> String
reverseColors text = "%{R}" ++ text ++ "%{R}"

align :: Alignment -> String -> String
align ALeft   text = "%{l}" ++ text ++ "%{l}"
align ACenter text = "%{c}" ++ text ++ "%{c}"
align ARight  text = "%{r}" ++ text ++ "%{r}"

changeColor :: ColorControl -> String -> String -> String
changeColor c color text = "%{" ++ show c ++ color ++ "}" ++ text ++ "%{" ++ show c ++ "-}"

clickable2 :: Show a => a -> [Char] -> [Char] -> [Char]
clickable2 n script text = "%{A" ++ show n ++ ":" ++ script ++ ":}" ++ text ++ "%{A}"
