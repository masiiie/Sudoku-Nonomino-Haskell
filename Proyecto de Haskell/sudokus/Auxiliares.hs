module Auxiliares where
    import Hugs.Observe

    union :: Eq a => [a] -> [a] -> [a]
    union l1 l2 = to_set (l1++l2)
    
    to_set :: Eq a => [a] -> [a]
    to_set [] = []
    to_set (r:rs) = if elem r ts then ts else [r]++ts
        where ts = to_set rs

    conjugate_n :: (Show a,Show b) => b -> (b->a->b) -> [a] -> b
    conjugate_n base funcion (p:ps)
        | length ps == 0 = funcion base p
        | otherwise = funcion param p
            where   param = conjugate_n base funcion ps

    select_min_length :: [[a]] -> Int
    select_min_length lista = length ff
        where
            lens = [length x|x <- lista]
            min = minimum lens
            ff = takeWhile (\x -> x /= min) lens


    index :: Int -> [a] -> a -> [a]
    index n lista value = fst p1 ++ [value] ++ snd p2
        where
            p1 = splitAt n lista
            p2 = splitAt 1 (snd p1)

    -- Asumo q la lista se indexa empezando por 0
    drop_nesimo :: [a] -> Int -> [a]
    drop_nesimo lista n = fst p1 ++ snd p2
        where 
            p1 = splitAt n lista
            p2 = splitAt 1 (snd p1)