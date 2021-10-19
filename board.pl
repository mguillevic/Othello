board([[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,x ,o ,_,_,_],
[_,_,_,o ,x ,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[_,_,_,_,_,_,_,_],
[]]).

opposite(x,o).
opposite(o,x).

succNum(0,1).
succNum(1,2).
succNum(2,3).
succNum(3,4).
succNum(4,5).
succNum(5,6).
succNum(6,7).
succNum(7,8).

printVal(Column, Row) :- board(B), nth0(Row, B, L), nth0(Column, L, Elem), var(Elem), write('-'), !.
printVal(Column, Row) :- board(B), nth0(Row, B, L), nth0(Column, L, Elem), write(Elem).
is_empty(List) :- not(member(_, List)).
display_row(N_row) :-  is_empty(board([N_row])), printVal(0, N_row), succNum(N_row, Var), display_row(Var).


display_board :- display_row(0).

