module Text.Parsec
  (
  ) where

data ParsecT s u m a

data Identity = Identity

type Parsec s u = ParsecT s u Identity

