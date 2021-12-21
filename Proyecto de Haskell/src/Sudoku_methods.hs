module Sudoku_methods (numlist_to_nonolist,can_make_sudoku,solve,init_sudoku) where
    import Auxiliares
    import Estructuras
    import Hugs.Observe

    sudoku_ok :: Sudoku -> Bool
    sudoku_ok Not_solution = False
    sudoku_ok (Sudoku nonos _) = (and filas_ok) && (and colums_ok) && (and non_ok) 
        where
            todo = sudoku_to_casillas nonos

            row_ok row = not_repeat same_row
                where same_row = [y| y <- todo, fst (pos y) == row]
            col_ok col = not_repeat same_col
                where same_col = [y| y <- todo, snd (pos y) == col]
            nono_ok nono = not_repeat (elements (nonos!!nono))

            filas_ok = map row_ok [0..8]
            colums_ok = map col_ok [0..8]
            non_ok = map nono_ok [0..8]

    not_repeat :: [Casilla] -> Bool
    not_repeat casillas = length (to_set [val x| x <- casillas, val x /= 0]) == 9


    solve :: Sudoku -> Sudoku
    solve Not_solution = Not_solution
    solve (Sudoku nonos []) = 
        if sudoku_ok (Sudoku nonos []) then bkpt "fib" $ observe "El sudoku tiene solucion" Sudoku nonos [] 
        else bkpt "fib" $ observe "El sudoku NO tiene solucion" Not_solution 
    solve (Sudoku nonos tsolve) = 
        if length cfijas > 0 then solve sudo2 
        else solve_aux (Sudoku nonos tsolve) to_mark_index 0 
        where
            cfijas = filter (\x-> length (snd x) == 1) tsolve
            fijas = [Casilla (fst x) (head (snd x)) | x <- cfijas]
            ts = filter (\x-> length (snd x) > 1) tsolve
            sudo1 = Sudoku nonos ts 
            sudo2 =  conjugate_n sudo1 clean_set fijas

            to_mark_index = select_min_length [snd x|x <- tsolve]

    
    solve_aux :: Sudoku -> Int -> Int -> Sudoku
    solve_aux (Sudoku nonos ts) index_pos indexx 
        | length (snd to_mark) == indexx = Not_solution
        | sudo3 == Not_solution = solve_aux (Sudoku nonos ts) index_pos (indexx+1)
        | otherwise = sudo3         
        where 
            to_mark = ts !! index_pos
            tsolve_new = index index_pos ts (fst to_mark, [ (snd to_mark) !! indexx ])
            sudo3 = solve (Sudoku nonos tsolve_new)

    can_fix :: Casilla -> [Casilla] -> Bool
    can_fix casilla same_row_col_nono = not (elem (val casilla) valores)
        where
            valores =  [val x| x <- same_row_col_nono]

    -- Recibe la casilla q va a fijarse, la fija y actualiza los valores de to_solve
    -- La casilla ya no esta en to_solve
    clean_set :: Sudoku -> Casilla -> Sudoku
    clean_set Not_solution _ = Not_solution
    clean_set (Sudoku nonos tsolve) casilla =
        if can_fix casilla marks then Sudoku nonos2 ts
        else Not_solution
        where
            todo = sudoku_to_casillas nonos
            nonomino = nonomino_casilla nonos (pos casilla)
            same_nono = [x| x <- elements (nonos!!nonomino), x /= casilla]
            same_row = [x| x <- todo, fst (pos x) == fst (pos casilla), x /= casilla]
            same_col = [x| x <- todo, snd (pos x) == snd (pos casilla), x /= casilla]
            marks = to_set [x | x<-(same_nono++same_row++same_col)]
            marks2 = [pos x|x<-marks]

            non2 = filter (\x-> pos x /= pos casilla) (elements (nonos!!nonomino)) ++ [casilla] 
            nonos2 = index nonomino nonos (Nonomino non2)
            ts = clean_condition tsolve (val casilla) (\x->elem x marks2)

    -- Elimina de los posibles valores el array to_remove (para las posiciones q cumplen la condicion) 
    clean_condition :: [((Int,Int),[Int])] -> Int -> ((Int,Int)->Bool) -> [((Int,Int),[Int])]
    clean_condition tsolve to_remove cond = no++[(fst x, filter filtro (snd x))| x<-tsolve, cond (fst x)]
            where
                no = [x|x<-tsolve, not (cond (fst x))]
                filtro = \y-> y /= to_remove

    -- Asumo q las decenas representan la region (comenzando por uno) y las unidades el valor de la casilla
    -- Convierte una lista de enteros a una de Nonominos
    numlist_to_nonolist :: [Int] -> [[Casilla]] -> [Nonomino]
    numlist_to_nonolist [] regiones = map (\x->Nonomino x) regiones
    numlist_to_nonolist (a:as) regiones = numlist_to_nonolist as newreg
        where
            value = mod a 10
            pos = 81 - (length as)
            fila = div (pos-1) 9
            columna = mod (pos-1) 9 
            casilla = Casilla (fila,columna) value
            reg = (div a 10)-1
            part1 = splitAt reg regiones
            part2 = splitAt 1 (snd part1)
            newreg = (fst part1)++[(fst part2)!!0++[casilla]]++(snd part2)


    can_make_sudoku :: [Nonomino] -> Bool
    can_make_sudoku nono = can_make_sudoku_aux nono [(x,y)|x <- [0..8], y <- [0..8]]

    can_make_sudoku_aux :: [Nonomino] -> [(Int,Int)] -> Bool
    can_make_sudoku_aux [] [] = True
    can_make_sudoku_aux [] t = False
    can_make_sudoku_aux t [] = False
    can_make_sudoku_aux (n:ns) lista = ok && can_make_sudoku_aux ns dif
        where 
            nono = [pos c | c <- elements n ]
            dif = filter (\x -> not (elem x nono)) lista
            ldif = length dif
            ll = length lista
            lnono = length (elements n)
            ok = (ldif==ll-lnono)

    sudoku_to_casillas :: [Nonomino] -> [Casilla]
    sudoku_to_casillas nonos = concat (map elements nonos)
    
    nonomino_element :: Nonomino -> (Int,Int) -> Bool
    nonomino_element nono poss = length (filter (\x -> pos x == poss) (elements nono)) > 0

    nonomino_casilla :: [Nonomino] -> (Int,Int) -> Int
    nonomino_casilla sudoku pos = length nott
        where
            nott = takeWhile (\x-> not (nonomino_element x pos)) sudoku

    init_sudoku :: [Nonomino] -> Sudoku
    init_sudoku nonos = Sudoku nonos tsolve
        where
            all = sudoku_to_casillas nonos 
            tsolve = [(pos x,[1..9])|x <- all, val x == 0] ++ [(pos x,[val x])|x <- all, val x /= 0]
