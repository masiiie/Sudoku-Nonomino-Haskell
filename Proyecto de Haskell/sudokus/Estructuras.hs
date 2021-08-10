module Estructuras (Casilla (Casilla), 
                    Nonomino (Nonomino), 
                    Sudoku (Sudoku, Not_solution), 
                    elements, pos, val,
                    nonominos, to_solve,
                    value_pos) 
                    where

    import Auxiliares
    import Hugs.Observe



    data Casilla = Casilla { pos::(Int,Int), val::Int } deriving Eq
    data Nonomino = Nonomino { elements::[Casilla] } deriving Eq
    data Sudoku = Sudoku { nonominos::[Nonomino], to_solve::[((Int,Int),[Int])]} | Not_solution deriving Eq

    show_sudoku :: Sudoku -> Int -> Int -> String
    show_sudoku (Sudoku nonos solv) fila columna
        | (Sudoku nonos solv) == Not_solution = "Sudoku sin solucion"
        | fila == 9 = "\n"
        | columna == 9 = "\n" ++ show_sudoku (Sudoku nonos solv) (fila+1) 0
        | otherwise = value ++ " " ++ show_sudoku (Sudoku nonos2 solv) fila (columna+1) 
            where
                secciones = ["A","B","C","D","E","F","G","H","I"]
                contains = span (\x-> value_pos x (fila,columna)==Nothing) nonos
                region = length (fst contains)
                Just number = value_pos ((snd contains)!!0) (fila,columna)
                value = (secciones!!region) ++ show number
                reg_deleted = filter (\x -> pos x /= (fila,columna)) (elements (nonos!!region))
                nonos2 = fst contains ++ [Nonomino reg_deleted] ++ drop 1 (snd contains)

    

    value_pos :: Nonomino -> (Int,Int) -> Maybe Int
    value_pos n poss = if length existing > 0 then Just (val (existing!!0)) else Nothing
        where
            existing = filter (\x -> pos x == poss) (elements n) 


    -- Un valor del 0-9 es una casilla del nonomino y X es q no pertenece al nonomino
    show_nonomino :: [Casilla] -> Int -> Int -> String
    show_nonomino nono fila columna
        | fila == 9 = "\n"
        | columna == 9 = "\n" ++ show_nonomino nono (fila+1) 0
        | otherwise = value ++ " " ++ show_nonomino nono2 fila (columna+1) 
            where
                busy = filter (\x -> pos x == (fila,columna)) nono
                value   | length busy == 0 = "X"  
                        | otherwise = show (val (busy!!0))
                nono2 = filter (\x -> pos x /= (fila,columna)) nono

    instance Show Nonomino where
        show n  = show_nonomino (elements n) 0 0

    instance Show Casilla where
        show casilla = "pos: " ++ show (pos casilla) ++ " value:" ++ show (val casilla) ++ "\n"

    instance Show Sudoku where
        show sudoku = show_sudoku sudoku 0 0