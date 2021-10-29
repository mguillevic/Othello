:-consult(coefficients).

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

getListElement(Symbol,Liste,Index):-nth0(Index,Liste,Symbol).
getMatrixElement(Symbol,Grid,X,Y):-
    getRow(Grid,X,Row), getListElement(Symbol,Row,Y).

evalRowWithCoeffs(_,_,_,[],0).
evalRowWithCoeffs(X,Y,Symbol,[Symbol|Q],Res):-
    coeffCase(X,Y,Coeff), Y1 is Y+1, evalRowWithCoeffs(X,Y1,Symbol,Q,Res2), 
    Res is Res2+Coeff.
evalRowWithCoeffs(X,Y,Symbol,[_|Q],Res):-
        Y1 is Y+1, evalRowWithCoeffs(X,Y1,Symbol,Q,Res).

evalWithCoeffs(_,_,[],0).
evalWithCoeffs(Player,X,[T|Q],Res):-
	hasSymbol(Player,Symbol),evalRowWithCoeffs(X,0,Symbol,T,ResLine), 
    X1 is X+1, evalWithCoeffs(Player,X1,Q,Res1),
    Res is Res1+ResLine,!.

getRow([Liste|_],0,Liste).
getRow([_|NextRows],Index,Row):-
    getRow(NextRows,I2,Row), Index is I2+1.

getColumn([],_,[]).
getColumn([T|Q],I,[R|X]):-
    getRow(T,I,R),getColumn(Q,I,X).
	

caseVide([T|_],0):-var(T).
caseVide([_|Q],I):-caseVide(Q,I1),I is I1+1.

caseVide(Grid,RowIndex,ColumnIndex):-
    getRow(Grid,RowIndex,Row),caseVide(Row,ColumnIndex).
	
evalWithCoeffs(maxPlayer,[
               [x,o,o,x,x,o,o,x],       -240
               [o,x,o,o,o,x,x,x],       -150
               [x,x,o,x,x,o,o,o],       +32
               [o,o,x,x,o,x,o,o],       +40
               [o,o,o,o,o,o,o,o],       +56
               [x,x,x,x,o,x,x,x],       +2
               [o,o,o,x,x,o,x,o],       -550
               [x,o,x,o,x,o,x,o]],      -420
               Res).
			   
			  