max([X],X).
max([T|Q],R):-max(Q,R), R>=T.
max([T|Q],T):-max(Q,R), T>R.

min([X],X).
min([T|Q],R):-min(Q,R), R<T.
min([T|Q],T):-min(Q,R), T=<R.

compterSymboles(_,[],0).
compterSymboles(Symbol,[Symbol|Q],Nb1):-
     compterSymboles(Symbol,Q,Nb2),Nb1 is Nb2+1.

compterSymboles(Symbol,[T|Q],Nb):-
    T\==Symbol,compterSymboles(Symbol,Q,Nb).

hasSymbol(maxPlayer,o).
hasSymbol(minPlayer,x).

otherPlayer(maxPlayer,minPlayer).
otherPlayer(minPlayer,maxPlayer).

compterPionsJoueur(Matrix,Player,Res):-
    flatten(Matrix,Liste),hasSymbol(Player,Symbol),
    compterSymboles(Symbol,Liste,Res).

eval(Grid,Player,Res):-
    otherPlayer(Player,P2), compterPionsJoueur(Grid,Player,N1),
    compterPionsJoueur(Grid,P2,N2), Res is N1-N2.

getRow([Liste|_],0,Liste).
getRow([_|NextRows],Index,Row):-
    getRow(NextRows,I2,Row), Index is I2+1.

getColumn([],_,[]).
getColumn([T|Q],I,[R|X]):-
    getRow(T,I,R),getColumn(Q,I,X).
	

caseVide([v|_],0).
caseVide([_|Q],I):-caseVide(Q,I1),I is I1+1.

caseVide(Grid,RowIndex,ColumnIndex):-
    getRow(Grid,RowIndex,Row),caseVide(Row,ColumnIndex).
	