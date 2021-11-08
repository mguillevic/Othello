:-consult(board)
:-consult(heuristics)
:-consult(utils)

%2 IA min_max avec la fonction d'évaluation coeff et avec des profondeurs d'exploration différentes
play_coeff_vs_coeff(Depth1,Depth2):-
	min_max(Board,maxPlayer,x,Depth1,2,BestTriple1), nth0(0,R,BestTriple1), nth0(1,C,BestTriple1),play_procedure(Board,x,R,C),
	min_max(Board,maxPlayer,o,Depth2,2,BestTriple2), nth0(0,X,BestTriple2), nth0(1,Y,BestTriple2),play_procedure(Board,x,X,Y).

%2 IA min_max avec la première qui évalue avec le nb de pions et l'autre qui évalue avec les coeff. Les 2 ont la même profondeur.
play_nbPions_vs_coeff():-
	min_max(Board,maxPlayer,x,5,1,BestTriple1), nth0(0,R,BestTriple1), nth0(1,C,BestTriple1),play_procedure(Board,x,R,C),
	min_max(Board,maxPlayer,o,5,2,BestTriple2), nth0(0,X,BestTriple2), nth0(1,Y,BestTriple2),play_procedure(Board,x,X,Y).