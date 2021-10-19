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

printVal(V) :- var(V), write('-'), !.
printVal(V) :- write(V).

display_row([]).
display_row([T|Q]) :-  display_char(T), write('\n'), display_row(Q).
display_char([]).
display_char([T|Q]) :-  printVal(T), display_char(Q).


display_board :- board(B), display_row(B).

