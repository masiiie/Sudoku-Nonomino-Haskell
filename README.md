# Sudoku-Nonomino-Haskell

It is a tool implemented in Haskell to simulate the **Nonomino Sudoku** game.

The necessary types are defined to express the logic of the game, as well as the implementation of the routines that, given an input of 9 *nonominos*, verify that a solution exists and grant it if it exists.

# Implementation explained


The types `Casilla`, `Nonomino` and `Sudoku` are defined where:
* A *Casilla* is represented by its position (Int, Int) in the sudoku puzzle and its value 1-9, 0 if it is empty.
* A *Nonomino* is a list of *Casilla*.
* A *Sudoku* can be a `Not_solution ` or, a set of `Nonomino` together with a list
