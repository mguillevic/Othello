board([[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,x ,o ,_,_,_],
[_,_,_,o ,x ,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_]]).

opposite(x,o).
opposite(o,x).

printVal(V) :- var(V), write('-'), !.
printVal(V) :- write(V).

display_row([]).
display_row([H|Q]) :-  display_char(H), write('\n'), display_row(Q).
display_char([]).
display_char([H|Q]) :-  printVal(H), display_char(Q).

display_board(B) :- display_row(B).

playMove(Board, Row, Column, NewBoard, Player) :- Board=NewBoard, nth0(Row, NewBoard, L), nth0(Column, L, Player) .