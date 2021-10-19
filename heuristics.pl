coeff(maxPlayer,1).
coeff(minPlayer,-1).

compterPions(_,[],0).
compterPions(Symbol,[Symbol|Q],Nb1):-
     compterPions(Symbol,Q,Nb2),Nb1 is Nb2+1.

compterPions(Symbol,[T|Q],Nb):-
    T\==Symbol,compterPions(Symbol,Q,Nb).

hasSymbol(maxPlayer,o).
hasSymbol(minPlayer,x).

eval(Matrix,Player,Res):-
    flatten(Matrix,Liste),hasSymbol(Player,Symbol),compterPions(Symbol,Liste,Res).