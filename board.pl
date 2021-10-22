opposite(x,o).
opposite(o,x).

:- dynamic board/1.

init :- retractall(board(Board)), length(Board,8), assertLength(Board), assert(board(Board)),playMove(Board, 4, 4, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 3, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 4, NewBoard, o), applyIt(Board,NewBoard), playMove(Board, 4, 3, NewBoard, o), applyIt(Board,NewBoard), play('x'), !.

assertLength([]).
assertLength([H|Q]) :- length(H,8), assertLength(Q).

play(Player) :- display_board, board(Board), write('C'), char_code(Guillemet, 39), write(Guillemet), write('est le tour de '), write(Player), writeln(' :'), write('Ligne'), read(R), write('Colonne'), read(C), 
(
(correct_move(Board, Player, R, C), playMove(Board, R, C, NewBoard, Player), applyIt(Board,NewBoard), opposite(Player, NewPlayer), play(NewPlayer))
;
play(Player)
).

printVal(V) :- var(V), write('-'), !.
printVal(V) :- write(V).

display_row([]).
display_row([H|Q]) :-  display_char(H), writeln(''), display_row(Q).
display_char([]).
display_char([H|Q]) :-  printVal(H), display_char(Q).

display_board :- cls, writeln('********'), board(Board), display_row(Board), writeln('********').
display_board(B) :- cls, writeln('********'), display_row(B), writeln('********').
cls :- write('').
%cls :- write('\e[H\e[2J').

playMove(Board, Row, Column, NewBoard, Player) :- NewBoard=Board, nth0(Row, NewBoard, L), nth0(Column, L, Player) .
applyIt(Board,NewBoard) :- retract(board(Board)), assert(board(NewBoard)).

get_element(Board, NbRow, NbCol, Val) :- nth0(NbRow,Board,Row), nth0(NbCol,Row,Val).
get_row(Board, NbRow, Row) :- nth0(NbRow,Board,Row).

compare_element(Board, Val, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Var), nonvar(Var), get_element(Board, NbRow, NbCol, Val).

correct_move(Board, Player, NbRow, NbCol) :- NbRowPrec is NbRow-1, NbRowSuiv is NbRow+1, NbColPrec is NbCol-1, NbColSuiv is NbCol+1, NbRowPrecPrec is NbRow-2, NbColPrecPrec is NbCol-2, NbRowSuivSuiv is NbRow+2, NbColSuivSuiv is NbCol+2, opposite(Player, Opposite), 
((compare_element(Board, Opposite, NbRowPrec, NbColPrec), correct_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec));
(compare_element(Board, Opposite, NbRowPrec, NbCol), correct_haut(Board, Player, NbRowPrecPrec, NbCol));
(compare_element(Board, Opposite, NbRowPrec, NbColSuiv), correct_diag_haut_droit(Board, Player, NbRowPrecPrec, NbColSuivSuiv));
(compare_element(Board, Opposite, NbRow, NbColPrec), correct_gauche(Board, Player, NbRow, NbColPrecPrec));
(compare_element(Board, Opposite, NbRow, NbColSuiv), correct_droit(Board, Player, NbRow, NbColSuivSuiv));
(compare_element(Board, Opposite, NbRowSuiv, NbColPrec), correct_diag_bas_gauche(Board, Player, NbRowSuivSuiv, NbColPrecPrec));
(compare_element(Board, Opposite, NbRowSuiv, NbCol), correct_bas(Board, Player, NbRowSuivSuiv, NbCol));
(compare_element(Board, Opposite, NbRowSuiv, NbColSuiv), correct_diag_bas_droit(Board, Player, NbRowSuivSuiv, NbColSuivSuiv)))/*,%creer les modify similaires au correct
(compare_element(Board, Opposite, NbRowPrec, NbColPrec), correct_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec), modify_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec)),
(compare_element(Board, Opposite, NbRowPrec, NbColPrec), correct_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec), modify_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec)),
(compare_element(Board, Opposite, NbRowPrec, NbColPrec), correct_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec), modify_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec)),
(compare_element(Board, Opposite, NbRowPrec, NbColPrec), correct_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec), modify_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec)),
(compare_element(Board, Opposite, NbRowPrec, NbColPrec), correct_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec), modify_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec)),
(compare_element(Board, Opposite, NbRowPrec, NbColPrec), correct_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec), modify_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec))*/. 

correct_diag_haut_gauche(Board, Player, -1, _) :- fail.
correct_diag_haut_gauche(Board, Player, _, -1) :- fail.
correct_diag_haut_gauche(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowPrec is NbRow-1, NbColPrec is NbCol-1, correct_diag_haut_gauche(Board, Player, NbRowPrec, NbColPrec))).

correct_diag_haut_droit(Board, Player, -1, _) :- fail.
correct_diag_haut_droit(Board, Player, _, 8) :- fail.
correct_diag_haut_droit(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowPrec is NbRow-1, NbColSuiv is NbCol+1, correct_diag_haut_droit(Board, Player, NbRowPrec, NbColSuiv))).

correct_diag_bas_gauche(Board, Player, 8, _) :- fail.
correct_diag_bas_gauche(Board, Player, _, -1) :- fail.
correct_diag_bas_gauche(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowSuiv is NbRow+1, NbColPrec is NbCol-1, correct_diag_bas_gauche(Board, Player, NbRowSuiv, NbColPrec))).

correct_diag_bas_droit(Board, Player, 8, _) :- fail.
correct_diag_bas_droit(Board, Player, _, 8) :- fail.
correct_diag_bas_droit(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowSuiv is NbRow+1, NbColSuiv is NbCol+1, correct_diag_bas_droit(Board, Player, NbRowSuiv, NbColSuiv))).

correct_haut(Board, Player, -1, _) :- fail.
correct_haut(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowPrec is NbRow-1, correct_haut(Board, Player, NbRowPrec, NbCol))).

correct_bas(Board, Player, 8, _) :- fail.
correct_bas(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowSuiv is NbRow+1, correct_bas(Board, Player, NbRowSuiv, NbCol))).

correct_gauche(Board, Player, _, -1) :- fail.
correct_gauche(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbColPrec is NbCol-1, correct_gauche(Board, Player, NbRow, NbColPrec))).

correct_droit(Board, Player, _, 8) :- fail.
correct_droit(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbColSuiv is NbCol+1, correct_droit(Board, Player, NbRow, NbColSuiv))).