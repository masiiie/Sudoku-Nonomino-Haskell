# Sudoku-Nonomino-Haskell

It is a tool implemented in Haskell to simulate the **Nonomino Sudoku** game.

The necessary types are defined to express the logic of the game, as well as the implementation of the routines that, given an input of 9 *nonominos*, verify that a solution exists and grant it if it exists.

To better understand the logic of the game and the orientation of the project see **Orientación de Proyecto de Haskell.pdf**

# Implementation explained

The `Casilla`, `Nonomino` and `Sudoku` types are defined in *Estructuras.hs*:
* A **Casilla** is represented by its position *(Int, Int)* in the sudoku puzzle and its value 1-9, 0 if it is empty.
* A **Nonomino** is a list of *Casilla*.
* A **Sudoku** can be a `Not_solution` or, a set of `Nonomino` together with a list of tuples, named `to_solve` , with the possible values that the empty squares of the board can take.



```haskell
data Casilla = Casilla { pos::(Int,Int), val::Int } deriving Eq
data Nonomino = Nonomino { elements::[Casilla] } deriving Eq
data Sudoku = Sudoku { nonominos::[Nonomino], to_solve::[((Int,Int),[Int])]} | Not_solution deriving Eq
```

The main methods for expressing the logic of the game are defined in *Sudoku_methods.hs* file.

The input is an array of integers *a*<sub>9\*i+j</sub> where the position *(9\*i+j)* represents the position *(i, j)* of the final sudoku puzzle. The number of the tens of *a*<sub>9\*i+j</sub> represents the nonomino to which it belongs and the units, the value of that position initially (if it is 0, it means that the box is empty).

`numlist_to_nonolist` method takes care of this first part, converts a list of integers with the explained format to a list of `Nonomino`. It is verified if the **Nonomino** list is valid to form a sudoku with  `can_make_sudoku` method.

```haskell
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
```

Finally, the board is solved with `solve` method. It is iterated until `to_solve` method has size 0, that is, every box has an assigned value. In each repetition of the cycle, the boxes whose list of values has size 1 are set and for each one the probable values of the boxes that are in the same row, column and nonomino are updated. If at some point, there are no boxes that can be set, then the one with the least probable values is taken and by *Backtracking* it is tested with what value from its list can give a valid solution to the sudoku puzzle. If at the time that a definitive value is to be assigned to a box, it is verified that that value already exists in that same row, column or nonomino, then it is determined that the sudoku has no solution, and a `Not_solution` is returned.



For printing, the constructed types are defined as **Show**, as well as the `show` function for each one.
