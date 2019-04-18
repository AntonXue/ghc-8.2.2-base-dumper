module Data.List.Utils where

spanList :: ([a] -> Bool) -> [a] -> ([a], [a])
spanList _ [] = ([],[])
spanList func list@(x:xs) =
    if func list
       then (x:ys,zs)
       else ([],list)
    where (ys,zs) = spanList func xs


breakList :: ([a] -> Bool) -> [a] -> ([a], [a])
breakList func = spanList (not . func)

