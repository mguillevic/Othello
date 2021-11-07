:-consult(coefficients).
:-consult(utils).

%Fonction d'évaluation simple qui compte juste le nombre de pions que possède le joueur donné
compterPionsJoueur(Matrix,Symbol,Res):-
    flatten(Matrix,Liste), compterSymboles(Symbol,Liste,Res).

%Pour savoir si une configuration est favorable ou non, on fait simplement la différence du nb de pions
eval(Grid,Symbol,Res):-
    opposite(Symbol,Opposite), compterPionsJoueur(Grid,Symbol,N1),
    compterPionsJoueur(Grid,Opposite,N2), Res is N1-N2.

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
evalWithCoeffs(Symbol,X,[T|Q],Res):-
	evalRowWithCoeffs(X,0,Symbol,T,ResLine),
    X1 is X+1, evalWithCoeffs(Symbol,X1,Q,Res1),
    Res is Res1+ResLine,!.

%Soit une liste de triplés de la forme (Row,Column,Eval), on récupère celui qui a la plus grande Eval.
%On peut ainsi déterminer, parmi une liste de coups, lequel est le plus intéressant.
maxTriple([Triple],Triple).
maxTriple([T|Q],R):-T==[-1,-1,u],maxTriple(Q,R). %Cas particulier où le triple est [-1,-1,u], correspond à la fin des coups possibles. On l'ignore
maxTriple([T|Q],T):-maxTriple(Q,R),R==[-1,-1,u].
maxTriple([T|Q],R):-nth0(2,T,Eval1),maxTriple(Q,R),nth0(2,R,Eval2),Eval2>=Eval1.
maxTriple([T|Q],T):-nth0(2,T,Eval1),maxTriple(Q,R),nth0(2,R,Eval2), Eval1>Eval2.

%Idem pour le min
minTriple([Triple],Triple).
minTriple([T|Q],R):-T==[-1,-1,u],minTriple(Q,R).
minTriple([T|Q],T):-minTriple(Q,R),R==[-1,-1,u].
minTriple([T|Q],R):-nth0(2,T,Eval1),minTriple(Q,R),nth0(2,R,Eval2),Eval2<Eval1.
minTriple([T|Q],T):-nth0(2,T,Eval1),minTriple(Q,R),nth0(2,R,Eval2), Eval1=<Eval2.

exampleBoard(Board):-
    Board=[[_,_,_,_,_,_,_,_],
           [_,_,_,o,_,_,_,_],
           [_,_,_,o,_,_,_,_],
           [_,_,o,o,o,_,_,_],
           [_,_,_,o,x,_,_,_],
           [_,_,_,x,_,_,_,_],
           [_,_,_,_,_,_,_,_],
           [_,_,_,_,_,_,_,_]
          ].

%Prédicat pour explorer tous les coups possibles à partir d'une situation donnée. Est appelé par l'algorithme min_max
%Renvoie un triple [X,Y,Eval]
explore_tree([],_,_,_,_,[-1,-1,u]). %Cas final, on renvoie un triple par défaut qui sera ignoré
explore_tree([T|Q],Board,Player,Symbol,Depth,ResTriple):-
	nth0(0,T,X), nth0(1,T,Y),
	remplacer(Board,X,Y,Symbol,NewBoard),
    otherPlayer(Player,Other), opposite(Symbol,Opposite),
	NewDepth is Depth-1,
	min_max(NewBoard,Other,Opposite,NewDepth,FinalTriple),
	nth0(2,FinalTriple,Res), CurrentTriple=[X,Y,Res],
	explore_tree(Q,Board,Player,Symbol,Depth,OtherTriple),
	(Player==maxPlayer ->                           %Selon à qui c'est le tour, on regarde le meilleur ou le pire coup à jouer
		maxTriple([CurrentTriple,OtherTriple],ResTriple);
		minTriple([CurrentTriple,OtherTriple],ResTriple)).

%Cas d'une feuille dans l'arbre de recherche lorsque l'on ne peut plus jouer ou que la profondeur vaut 0.
min_max(CurrentGrid,Player,Symbol,Depth,Triple,TypeEval):-
    ((possible_to_play(CurrentGrid,Symbol,Possible),Possible='N');Depth=0),
	(TypeEval==1 ->
		compterPionsJoueur(CurrentGrid,Symbol,EvalJoueur);      %On choisit la fonction d'évaluation
		evalWithCoeffs(Player,0,CurrentGrid,EvalJoueur)), 
	coeffJoueur(Player,Coeff),
    Res is EvalJoueur*Coeff, Triple = [-1,-1,Res].  %Seul Res nous intéresse, on renvoie -1 par convention

%Dans les autres cas, on détermine tous les coups possibles, puis on appelle récursivement min_max pour chacun d'eux
min_max(Board,Player,Symbol,Depth,BestTriple):-
    list_possible_correct_moves(Board,Symbol,Moves),
	findall([R,C],get_element(Moves,R,C,'Y'),ListCoords),
	explore_tree(ListCoords,Board,Player,Symbol,Depth,BestTriple).

test(Result):-
    exampleBoard(Board),min_max(Board,minPlayer,x,1,Result).




