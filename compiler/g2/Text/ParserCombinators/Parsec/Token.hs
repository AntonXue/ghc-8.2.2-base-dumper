module Text.ParserCombinators.Parsec.Token
  ( commentStart
  , commentEnd
  , commentLine
  , nestedComments
  , identStart
  , identLetter
  , reservedNames
  , makeTokenParser
  , identifier
  ) where

commentStart :: a
commentStart = error "commentStart"

commentEnd :: a
commentEnd = error "commentEnd"

commentLine :: a
commentLine = error "commentLine"

nestedComments :: a
nestedComments = error "nestedComments"

identStart :: a
identStart = error "identStart"

identLetter :: a
identLetter = error "identLetter"

reservedNames :: a
reservedNames = error "reservedNames"

makeTokenParser :: a
makeTokenParser = error "makeTokenParser"

identifier :: a
identifier = error "identifier"


