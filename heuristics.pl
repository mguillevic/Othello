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

%Dans une configuration donnée, renvoie le meilleur coup que peut faire un joueur, au sens de la fonction d'évaluation
bestMove(Player,X,Y):-
    example_Board(Board),
	liste_triples(Board,Player,List),maxTriple(List,Triple), 
    nth0(0,Triple,X), nth0(1,Triple,Y).
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
explore_tree([],_,_,_,[-1,-1,u]). %Cas final, on renvoie un triple par défaut qui sera ignoré
explore_tree([T|Q],Board,Player,Depth,ResTriple):-
	nth0(0,T,X), nth0(1,T,Y), hasSymbol(Player,Symbol),
	remplacer(Board,X,Y,Symbol,NewBoard), otherPlayer(Player,Other),
	NewDepth is Depth-1,
	min_max(NewBoard,Other,NewDepth,FinalTriple),
	nth0(2,FinalTriple,Res), CurrentTriple=[X,Y,Res],
	explore_tree(Q,Board,Player,Depth,OtherTriple),
	(Player==maxPlayer ->                           %Selon à qui c'est le tour, on regarde le meilleur ou le pire coup à jouer
		maxTriple([CurrentTriple,OtherTriple],ResTriple);
		minTriple([CurrentTriple,OtherTriple],ResTriple)).
		
%Cas d'une feuille dans l'arbre de recherche lorsque l'on ne peut plus jouer ou que la profondeur vaut 0.
min_max(CurrentGrid,Player,Depth,Triple):-
    hasSymbol(Player,Symbol),
    ((possible_to_play(CurrentGrid,Symbol,Possible),Possible='N');Depth=0),
    evalWithCoeffs(Player,0,CurrentGrid,EvalJoueur), coeffJoueur(Player,Coeff),
    Res is EvalJoueur*Coeff, Triple = [-1,-1,Res].  %Seul Res nous intéresse, on renvoie -1 par convention
	
%Dans les autres cas, on détermine tous les coups possibles, puis on appelle récursivement min_max pour chacun d'eux
min_max(Board,Player,Depth,BestTriple):-
	hasSymbol(Player,Symbol),list_possible_correct_moves(Board,Symbol,Moves),
	findall([R,C],get_element(Moves,R,C,'Y'),ListCoords),
	explore_tree(ListCoords,Board,Player,Depth,BestTriple).
	
test(Result):-
    exampleBoard(Board),min_max(Board,minPlayer,4,Result).
	
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
			   

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ALPHA - BETA~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

afficherPionsJoueur(Player):-
    exampleBoard(Board), hasSymbol(Player,Symbol), CompterPionsJoueur(Board,Symbol,Res), 
    write('Le joueur : '), write(Player), write('possede '), write(Res), write('pions').
			  