:-consult(board).

%2 IA min_max avec la fonction d'évaluation coeff et avec des profondeurs d'exploration différentes

start_play(Player,D1,D2) :- board(Board), opposite(Player,OppositePlayer),
possible_to_play(Board, OppositePlayer, OtherPossible), (OtherPossible='Y', play_coeff_vs_coeff(OppositePlayer, D1,D2)) ; game_over(Board).

play_Procedure(Board, Player,D1,D2, R, C) :- 
correct_move(Board, Player, R, C), reverse_elements(Board, Player, R, C),board(NewBoard), 
playMove(NewBoard, R, C, NewNewBoard, Player), applyIt(NewBoard,NewNewBoard), start_play(Player,D2,D1).

play_coeff_vs_coeff(Player,Depth1,Depth2,R,C):-
	board(Board),
	min_max(Board,maxPlayer,Player,Depth1,2,BestTriple1), nth0(0,R,BestTriple1), nth0(1,C,BestTriple1).
	play_Procedure(Board,Player,Depth1,Depth2,R,C).

%2 IA min_max avec la première qui évalue avec le nb de pions et l'autre qui évalue avec les coeff. Les 2 ont la même profondeur.
play_nbPions_vs_coeff:-
	min_max(Board,maxPlayer,x,5,1,BestTriple1), nth0(0,R,BestTriple1), nth0(1,C,BestTriple1),play_procedure(Board,x,R,C),
	min_max(Board,maxPlayer,o,5,2,BestTriple2), nth0(0,X,BestTriple2), nth0(1,Y,BestTriple2),play_procedure(Board,x,X,Y).
	
myTest(R,C,Res):-
	retractall(board(Board)), length(Board,8), assertLength(Board), assert(board(Board)),playMove(Board, 4, 4, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 3, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 4, NewBoard, o), applyIt(Board,NewBoard), playMove(Board, 4, 3, NewBoard, o), applyIt(Board,NewBoard),
	play_coeff_vs_coeff(x,10,5,R,C).