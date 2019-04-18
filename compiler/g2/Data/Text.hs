module Data.Text
  ( Text
  , pack
  , unpack
  ) where

type Text = String

pack :: String -> Text
pack = id

unpack :: Text -> String
unpack = id

