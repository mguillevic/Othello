opposite(x,o).
opposite(o,x).

:- dynamic board/1.

init :- retractall(board(Board)), length(Board,8), assertLength(Board), assert(board(Board)),playMove(Board, 4, 4, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 3, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 4, NewBoard, o), applyIt(Board,NewBoard), playMove(Board, 4, 3, NewBoard, o), applyIt(Board,NewBoard), play('x'), !.

assertLength([]).
assertLength([H|Q]) :- length(H,8), assertLength(Q).

play(Player) :- display_board, write('Ligne :'), read(R), write('Colonne :'), read(C), playMove(Board, R, C, NewBoard, Player), applyIt(Board,NewBoard), opposite(Player, NewPlayer), play(NewPlayer).

printVal(V) :- var(V), write('-'), !.
printVal(V) :- write(V).

display_row([]).
display_row([H|Q]) :-  display_char(H), write('\n'), display_row(Q).
display_char([]).
display_char([H|Q]) :-  printVal(H), display_char(Q).

display_board :- cls, board(Board), display_row(Board).
display_board(B) :- cls, display_row(B).
cls :- write('\e[H\e[2J').

playMove(Board, Row, Column, NewBoard, Player) :- NewBoard=Board, nth0(Row, NewBoard, L), nth0(Column, L, Player) .
applyIt(Board,NewBoard) :- retract(board(Board)), assert(board(NewBoard)).