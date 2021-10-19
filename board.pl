board([[a,_,_,_,_,_,_,y],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,x ,o ,_,_,_],
[_,_,_,o ,x ,_,_,_],
[_,_,_,_,_,_,_,_],
[f,_,_,_,_,_,_,_],
[d,_,_,_,_,_,_,_]]).

opposite(x,o).
opposite(o,x).

succNum(0,1).
succNum(1,2).
succNum(2,3).
succNum(3,4).
succNum(4,5).
succNum(5,6).
succNum(6,7).

printVal(Column, Row) :- board(B), nth0(Row, B, L), nth0(Column, L, Elem), var(Elem), write('-'), !.
printVal(Column, Row) :- board(B), nth0(Row, B, L), nth0(Column, L, Elem), write(Elem).

display_row(N_row) :-  display_char(0, N_row), write('\n'), succNum(N_row, Var), display_row(Var).
display_char(7, N_row) :-  printVal(N_char, N_row).
display_char(N_char, N_row) :-  printVal(N_char, N_row), succNum(N_char, Var), display_char(Var, N_row).


display_board :- display_row(0).

