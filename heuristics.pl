:-consult(coefficients).
:-consult(utils).

%fonction qui renvoie un coup random parmi une liste de coups autorises
random_move(ListesCoord,R,C):-random_member(Coord,ListesCoord),nth0(0,Coord,R),nth0(1,Coord,C).

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
           [_,_,_,_,_,_,_,_],
           [_,_,_,o,_,_,_,_],
           [_,_,o,o,o,_,_,_],
           [_,_,_,o,x,_,_,_],
           [_,_,_,x,_,_,_,_],
           [_,_,_,_,_,_,_,_],
           [_,_,_,_,_,_,_,_]
          ].

%Prédicat pour explorer tous les coups possibles à partir d'une situation donnée. Est appelé par l'algorithme min_max
%Renvoie un triple [X,Y,Eval]
explore_tree([T|[]],Board,Player,Symbol,Depth,TypeEval,ResTriple):- %Cas final, on renvoie un triple par défaut qui sera ignoré
    nth0(0,T,X), nth0(1,T,Y),
    remplacer(Board,X,Y,Symbol,NewBoard),
    otherPlayer(Player,Other), opposite(Symbol,Opposite),
    NewDepth is Depth-1,
    min_max(NewBoard,Other,Opposite,NewDepth,TypeEval,FinalTriple),
    nth0(2,FinalTriple,Res), ResTriple=[X,Y,Res].

explore_tree([T|Q],Board,Player,Symbol,Depth,TypeEval,ResTriple):-
	nth0(0,T,X), nth0(1,T,Y),
	remplacer(Board,X,Y,Symbol,NewBoard), reverse_elements(NewBoard,Symbol,X,Y,NewBoard2),
    otherPlayer(Player,Other), opposite(Symbol,Opposite),
	NewDepth is Depth-1,
	min_max(NewBoard2,Other,Opposite,NewDepth,TypeEval,FinalTriple),
	nth0(2,FinalTriple,Res), CurrentTriple=[X,Y,Res],
	explore_tree(Q,Board,Player,Symbol,Depth,TypeEval,OtherTriple),
    ((OtherTriple=[-1, -1, u], ResTriple=CurrentTriple) ;
	(Player==maxPlayer ->                           %Selon à qui c'est le tour, on regarde le meilleur ou le pire coup à jouer
		((OtherTriple=[-1,-1,u], ResTriple=CurrentTriple) ; maxTriple([CurrentTriple,OtherTriple],ResTriple));
		minTriple([CurrentTriple,OtherTriple],ResTriple))).

%Cas d'une feuille dans l'arbre de recherche lorsque l'on ne peut plus jouer ou que la profondeur vaut 0.
min_max(CurrentGrid,Player,Symbol,Depth,TypeEval,Triple):-
    ((possible_to_play(CurrentGrid,Symbol,Possible),Possible='N');Depth=0),
	((TypeEval=1,compterPionsJoueur(CurrentGrid,Symbol,EvalJoueur));      %On choisit la fonction d'évaluation
		evalWithCoeffs(Symbol,0,CurrentGrid,EvalJoueur)),
	coeffJoueur(Player,Coeff),
    Res is EvalJoueur*Coeff, Triple = [-1,-1,Res].  %Seul Res nous intéresse, on renvoie -1 par convention

%Dans les autres cas, on détermine tous les coups possibles, puis on appelle récursivement min_max pour chacun d'eux
min_max(Board,Player,Symbol,Depth,TypeEval,BestTriple):-
    list_possible_correct_moves(Board,Symbol,Moves),
	findall([R,C],get_element(Moves,R,C,'Y'),ListCoords),
	explore_tree(ListCoords,Board,Player,Symbol,Depth,TypeEval,BestTriple).

test(Result):-
    exampleBoard(Board),min_max(Board,minPlayer,x,1,2,Result).


afficherPionsJoueur(Player):- exampleBoard(Board), writeln(Board), hasSymbol(Player,Symbol), compterPionsJoueur(Board,Symbol,Res), write('Le joueur : '), write(Symbol), write('possede '), write(Res), write('pions').

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ALPHA - BETA~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%Le but des parcoursTree est comme min max de trouver le meilleur coup, mais en elaguant l'arbre de recherche. Ainsi, pour chaque noeud, on parcourt tous ses enfants, mais on a une condition d'arret qui peut nous arreter en plein milieu. En effet le principe de l'algorithme alpha-beta est de detecter certaines parties de l'arbre qui sont inutiles a parcourir.
%Chaque fois qu'on arrive dans un predicat, on a le noeud actuel (T) et la liste de ses enfants en second parametre. Le but est de parcourir tous ses enfants (en s'arretant potentiellement si la condition d'arret alpha>=beta est verifiee). Pour ce faire, on parcourt le premier enfant du noeud puis on se refait appel a soi meme en enlevant le head des enfants. Ainsi, le prochain appel va appeler le second enfant, puis va faire un autre appel qui va appeler le troisieme enfant et ainsi de suite. La condition d'arret est qu'on recoit une liste composee d'un unique enfant, dans ce cas la on va l'appeler puis on va depiler. Ce depilement va permettre de renvoyer la valeur d'evaluation du noeud jusqu'au debut.

parcoursTree(T,[],Player,MaximizingPlayer,_,Board,Res,_,_,_,_,_):-T=[R,C], reverse_elements(Board, Player, R, C,TempBoard), playMove(TempBoard, R, C, NewBoard, Player),evalWithCoeffs(MaximizingPlayer,0,NewBoard,Res).%eval(NewBoard,MaximizingPlayer,Res).

parcoursTree(T,_,Player,MaximizingPlayer,0,Board,Res,_,_,_,_,_):-T=[R,C], reverse_elements(Board, Player, R, C,TempBoard), playMove(TempBoard, R, C, NewBoard, Player),evalWithCoeffs(MaximizingPlayer,0,NewBoard,Res).%,eval(NewBoard,MaximizingPlayer,Res).

parcoursTree(T,[Q|[]],Player,Player,Depth,Board,Res,PrecRes,A,B,PrecBestMove,BestMove):- 
    T=[R,C], reverse_elements(Board, Player, R, C,TempBoard), playMove(TempBoard, R, C, NewBoard, Player),
    ((nonvar(PrecRes), MaxEval is PrecRes); MaxEval is -1.0Inf), NewDepth is Depth-1, opposite(Player,OtherPlayer), MyA is A, MyB is B,
    Q=[R2,C2], reverse_elements(NewBoard, Player, R2, C2,TempBoard2), playMove(TempBoard2, R2, C2, NewBoard2, Player),
    list_possible_correct_moves2(NewBoard2, Player, Q2), parcoursTree(Q,Q2,OtherPlayer,Player,NewDepth,NewBoard,ResE,_,MyA,MyB,_,_),
    max([MaxEval, ResE], NewMaxEval), max([MyA,ResE],MyNewA), Res is NewMaxEval,
    ((ResE>MaxEval, BestMove=Q);(nonvar(PrecBestMove),BestMove=PrecBestMove);BestMove=Q).

parcoursTree(T,[Q|[]],Player,MaximizingPlayer,Depth,Board,Res,PrecRes,A,B,PrecBestMove,BestMove):-
    opposite(Player,MaximizingPlayer),
    T=[R,C], reverse_elements(Board, Player, R, C,TempBoard), playMove(TempBoard, R, C, NewBoard, Player),
    ((nonvar(PrecRes), MinEval is PrecRes); MinEval is 1.0Inf), NewDepth is Depth-1, MyA is A, MyB is B,
    Q=[R2,C2], reverse_elements(NewBoard, Player, R2, C2,TempBoard2), playMove(TempBoard2, R2, C2, NewBoard2, Player),
    list_possible_correct_moves2(NewBoard2, Player, Q2), parcoursTree(Q,Q2,MaximizingPlayer,MaximizingPlayer,NewDepth,NewBoard,ResE,_,MyA,MyB,_,_),
    min([MinEval,ResE],NewMinEval), min([MyB,ResE],MyNewB),Res is NewMinEval,
    ((ResE<MinEval, BestMove=Q);(nonvar(PrecBestMove),BestMove=PrecBestMove);BestMove=Q).

parcoursTree(T,[Q1|Q3],Player,Player,Depth,Board,Res,PrecRes,A,B,PrecBestMove,BestMove):-
    T=[R,C], reverse_elements(Board, Player, R, C,TempBoard), playMove(TempBoard, R, C, NewBoard, Player),
    ((nonvar(PrecRes), MaxEval is PrecRes); MaxEval is -1.0Inf), NewDepth is Depth-1, opposite(Player,OtherPlayer), MyA is A, MyB is B,
    Q1=[R2,C2], reverse_elements(NewBoard, Player, R2, C2,TempBoard2), playMove(TempBoard2, R2, C2, NewBoard2, Player),
    list_possible_correct_moves2(NewBoard2, Player, Q2), parcoursTree(Q1,Q2,OtherPlayer,Player,NewDepth,NewBoard,ResE,_,MyA,MyB,_,_),
    ((ResE>MaxEval, BestMoveActueal=Q1);(nonvar(PrecBestMove),BestMoveActueal=PrecBestMove);BestMoveActueal=Q1),
    max([MaxEval, ResE], NewMaxEval), max([MyA,ResE],MyNewA),
    ((MyB>MyNewA, parcoursTree(T,Q3,Player,Player,Depth,Board,ResF,NewMaxEval,MyNewA,MyB,BestMoveActueal,BestMove), Res is ResF);
    Res is NewMaxEval).

parcoursTree(T,[Q1|Q3],Player,MaximizingPlayer,Depth,Board,Res,PrecRes,A,B,PrecBestMove,BestMove):-
opposite(Player,MaximizingPlayer), T=[R,C],
    reverse_elements(Board, Player, R, C,TempBoard), playMove(TempBoard, R, C, NewBoard, Player),
    ((nonvar(PrecRes), MinEval is PrecRes); MinEval is 1.0Inf),
    NewDepth is Depth-1, MyA is A, MyB is B,
    Q1=[R2,C2], reverse_elements(NewBoard, Player, R2, C2,TempBoard2), playMove(TempBoard2, R2, C2, NewBoard2, Player),
    list_possible_correct_moves2(NewBoard2, Player, Q2), parcoursTree(Q1,Q2,MaximizingPlayer,MaximizingPlayer,NewDepth,NewBoard,ResE,_,MyA,MyB,_,_),
    ((ResE<MinEval, BestMoveActueal=Q1);(nonvar(PrecBestMove),BestMoveActueal=PrecBestMove);BestMoveActueal=Q1),
    min([MinEval,ResE],NewMinEval), min([MyB,ResE],MyNewB),
    ((MyNewB>MyA, parcoursTree(T,Q3,Player,MaximizingPlayer,Depth,Board,ResF,NewMinEval,MyA,MyNewB, BestMoveActueal, BestMove), Res is ResF);
    Res is NewMinEval).

%On a besoin de distinguer le cas du premier appel a alpha_beta des autres. En effet, pour le premier appel, on a juste un etat et pas de coup initial. Le fonctionnement est identique aux predicats du dessus a la difference qu'on n'effectue pas de coup initial au debut.
parcoursTree([Q|[]],Player,Player,Depth,NewBoard,Res,PrecRes,A,B,PrecBestMove,BestMove,first):- 
    ((nonvar(PrecRes), MaxEval is PrecRes); MaxEval is -1.0Inf), NewDepth is Depth-1, opposite(Player,OtherPlayer), MyA is A, MyB is B,
    Q=[R2,C2], reverse_elements(NewBoard, Player, R2, C2,TempBoard2), playMove(TempBoard2, R2, C2, NewBoard2, Player),
    list_possible_correct_moves2(NewBoard2, Player, Q2), parcoursTree(Q,Q2,OtherPlayer,Player,NewDepth,NewBoard,ResE,_,MyA,MyB,_,_),
    max([MaxEval, ResE], NewMaxEval), max([MyA,ResE],MyNewA), Res is NewMaxEval,
    ((ResE<MaxEval, BestMove=Q);(nonvar(PrecBestMove),BestMove=PrecBestMove);BestMove=Q).

parcoursTree([Q|[]],Player,MaximizingPlayer,Depth,NewBoard,Res,PrecRes,A,B,PrecBestMove,BestMove,first):-
    opposite(Player,MaximizingPlayer),
    ((nonvar(PrecRes), MinEval is PrecRes); MinEval is 1.0Inf), NewDepth is Depth-1, MyA is A, MyB is B,
    Q=[R2,C2], reverse_elements(NewBoard, Player, R2, C2,TempBoard2), playMove(TempBoard2, R2, C2, NewBoard2, Player),
    list_possible_correct_moves2(NewBoard2, Player, Q2), parcoursTree(Q,Q2,MaximizingPlayer,MaximizingPlayer,NewDepth,NewBoard,ResE,_,MyA,MyB,_,_),
    min([MinEval,ResE],NewMinEval), min([MyB,ResE],MyNewB),Res is NewMinEval,
    ((ResE>MinEval, BestMove=Q);(nonvar(PrecBestMove),BestMove=PrecBestMove);BestMove=Q).

parcoursTree([Q1|Q3],Player,Player,Depth,NewBoard,Res,PrecRes,A,B,PrecBestMove,BestMove,first):-
    ((nonvar(PrecRes), MaxEval is PrecRes); MaxEval is -1.0Inf), NewDepth is Depth-1, opposite(Player,OtherPlayer), MyA is A, MyB is B,
    Q1=[R2,C2], reverse_elements(NewBoard, Player, R2, C2,TempBoard2), playMove(TempBoard2, R2, C2, NewBoard2, Player),
    list_possible_correct_moves2(NewBoard2, Player, Q2),parcoursTree(Q1,Q2,OtherPlayer,Player,NewDepth,NewBoard,ResE,_,MyA,MyB,_,_),
    ((ResE>MaxEval, BestMoveActueal=Q1);(nonvar(PrecBestMove),BestMoveActueal=PrecBestMove);BestMoveActueal=Q1),
    max([MaxEval, ResE], NewMaxEval), max([MyA,ResE],MyNewA),
    ((MyB>MyNewA, parcoursTree(Q3,Player,Player,Depth,NewBoard,ResF,NewMaxEval,MyNewA,MyB,BestMoveActueal,BestMove,first), Res is ResF);
    Res is NewMaxEval).

parcoursTree([Q1|Q3],Player,MaximizingPlayer,Depth,NewBoard,Res,PrecRes,A,B,PrecBestMove,BestMove,first):-
    opposite(Player,MaximizingPlayer), 
    ((nonvar(PrecRes), MinEval is PrecRes); MinEval is 1.0Inf),
    NewDepth is Depth-1, MyA is A, MyB is B,
    Q1=[R2,C2], reverse_elements(NewBoard, Player, R2, C2,TempBoard2), playMove(TempBoard2, R2, C2, NewBoard2, Player),list_possible_correct_moves2(NewBoard2, Player, Q2), parcoursTree(Q1,Q2,MaximizingPlayer,MaximizingPlayer,NewDepth,NewBoard,ResE,_,MyA,MyB,_,_),
    ((ResE<MinEval, BestMoveActueal=Q1);(nonvar(PrecBestMove),BestMoveActueal=PrecBestMove);BestMoveActueal=Q1),
    min([MinEval,ResE],NewMinEval), min([MyB,ResE],MyNewB),
    ((MyNewB>MyA, parcoursTree(Q3,Player,MaximizingPlayer,Depth,NewBoard,ResF,NewMinEval,MyA,MyNewB, BestMoveActueal, BestMove,first), Res is ResF);
    Res is NewMinEval).

%Si aucun des predicats du dessus n'est reconnu (ce qui ne serait pas normal), on tombe dans ces predicats qui nous previennent parce qu'on pourrait ne meme pas le remarquer. Ca aide surtout pour le debug mais pas necessaire en soi pour le jeu.
parcoursTree(_,_,_,_,_,_,_,_,_,_,_,first):-writeln("Probleme parcoursTree").

parcoursTree(_,_,_,_,_,_,_,_,_,_,_,_):-writeln("Probleme parcoursTree").

%predicat appele pour recuperer le meilleur coup. Il va faire appel au parcours de l'arbre a partir de l'etat du plateau donne en parametre.
getMoveAlphaBeta(Board,Player,Profondeur,BestMove) :- list_possible_correct_moves2(Board, Player, CorrectMoves),A is -1.0Inf,B is 1.0Inf,parcoursTree(CorrectMoves,Player,Player,Profondeur,Board,_,_,A,B,_,BestMove,first).