:-consult(coefficients).
:-consult(utils).


%Fonction d'évaluation simple qui compte juste le nombre de pions que possède le joueur donné
compterPionsJoueur(Matrix,Player,Res):-
    flatten(Matrix,Liste),hasSymbol(Player,Symbol),
    compterSymboles(Symbol,Liste,Res).

%Pour savoir si une configuration est favorable ou non, on fait simplement la différence du nb de pions
eval(Grid,Player,Res):-
    otherPlayer(Player,P2), compterPionsJoueur(Grid,Player,N1),
    compterPionsJoueur(Grid,P2,N2), Res is N1-N2.

%Renvoie le nb de points d'une ligne du plateau en prenant en compte des coefficients, c'est à dire que des cases sont plus intéressantes que d'autre
evalRowWithCoeffs(_,_,_,[],0).
evalRowWithCoeffs(X,Y,Symbol,[T|Q],Res):-
    nonvar(T), Symbol==T,
    coeffCase(X,Y,Coeff),Y1 is Y+1, 
    evalRowWithCoeffs(X,Y1,Symbol,Q,Res2), Res is Res2+Coeff.
evalRowWithCoeffs(X,Y,Symbol,[_|Q],Res):-
        Y1 is Y+1, evalRowWithCoeffs(X,Y1,Symbol,Q,Res).

%Pareil que précédemment, mais appliqué à tout le plateau et pas juste à une ligne. X doit être instancié à 0.
evalWithCoeffs(_,_,[],0).
evalWithCoeffs(Player,X,[T|Q],Res):-
	hasSymbol(Player,Symbol),evalRowWithCoeffs(X,0,Symbol,T,ResLine), 
    X1 is X+1, evalWithCoeffs(Player,X1,Q,Res1),
    Res is Res1+ResLine,!.

liste_coordonnees(Board,List):- findall([X,Y],get_element(Board,X,Y,'Y'),List).

%Renvoie le triplé [X,Y,Evaluation] pour un coup aux coordonnées X,Y.
make_triple(Board,Player,X,Y,Triple):-
    hasSymbol(Player,Symbol),remplacer(Board,X,Y,Symbol,NewBoard),
    evalWithCoeffs(Player,0,NewBoard,Res), Triple=[X,Y,Res].

%Pour chaque coup que peut effectuer un joueur, renvoie le triplé (X,Y,Score) avec Score l'évaluation du jeu si on met le pion aux coordonnées (X,Y).
liste_triples(Board,Player,List):-
    example_Board(Board),
    hasSymbol(Player,Symbol),list_possible_correct_moves(Board,Symbol,Moves),
    findall(Triple,(get_element(Moves,X,Y,'Y'),make_triple(Board,Player,X,Y,Triple)),List).

%Soit une liste de triplés de la forme (Row,Column,Eval), on récupère celui qui a la plus grande Eval.
%On peut ainsi déterminer, parmi une liste de coups, lequel est le plus intéressant.
maxTriple([Triple],Triple).
maxTriple([T|Q],R):-nth0(2,T,Eval1),maxTriple(Q,R),nth0(2,R,Eval2),Eval2>=Eval1.
maxTriple([T|Q],T):-nth0(2,T,Eval1),maxTriple(Q,R),nth0(2,R,Eval2),Eval1>Eval2.

%Dans une configuration donnée, renvoie le meilleur coup que peut faire un joueur, au sens de la fonction d'évaluation
bestMove(Player,X,Y):-
    example_Board(Board),
	liste_triples(Board,Player,List),maxTriple(List,Triple), 
    nth0(0,Triple,X), nth0(1,Triple,Y).

min_max(CurrentGrid,Player,Depth,Res,_,_):-
    ((possible_to_play(CurrentGrid,Player,Possible),Possible='N');Depth=0),
    evalWithCoeffs(Player,0,CurrentGrid,EvalJoueur), coeffJoueur(Player,Coeff),
    Res is EvalJoueur*Coeff.
	
	
# evalWithCoeffs(maxPlayer,0,[
               # [x,o,o,x,x,o,o,x],       -240
               # [o,x,o,o,o,x,x,x],       -150
               # [x,x,o,x,x,o,o,o],       +32
               # [o,o,x,x,o,x,o,o],       +40
               # [o,o,o,o,o,o,o,o],       +56
               # [x,x,x,x,o,x,x,x],       +2
               # [o,o,o,x,x,o,x,o],       -550
               # [x,o,x,o,x,o,x,o]],      -420
               # Res).
			   
			  