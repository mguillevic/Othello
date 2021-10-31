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

getRow([Liste|_],0,Liste).
getRow([_|NextRows],Index,Row):-
    getRow(NextRows,I2,Row), Index is I2+1.

getColumn([],_,[]).
getColumn([T|Q],I,[R|X]):-
    getRow(T,I,R),getColumn(Q,I,X).
	
getListElement(Symbol,Liste,Index):-nth0(Index,Liste,Symbol).
getMatrixElement(Symbol,Grid,X,Y):-
    getRow(Grid,X,Row), getListElement(Symbol,Row,Y).

caseVide([T|_],0):-var(T).
caseVide([_|Q],I):-caseVide(Q,I1),I is I1+1.

caseVide(Grid,RowIndex,ColumnIndex):-
    getRow(Grid,RowIndex,Row),caseVide(Row,ColumnIndex).