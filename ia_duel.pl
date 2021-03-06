:-consult(board).
:-dynamic win_min_max/1.
:-dynamic win_random/1.
:-dynamic nb_parties/1.
:-dynamic tps_depart/1.

init_ia :- retractall(board(Board)), length(Board,8), assertLength(Board), assert(board(Board)),playMove(Board, 4, 4, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 3, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 4, NewBoard, o), applyIt(Board,NewBoard), playMove(Board, 4, 3, NewBoard, o), applyIt(Board,NewBoard), start_play_ia('x'), !,win_random(NewWin_random), win_min_max(NewWin_min_max),
tps_depart(Tps_depart),nb_parties(Nb_parties),
get_time(Tps_fin), Tps_diff is Tps_fin - Tps_depart, Tps_moy is Tps_diff/Nb_parties,
write('NB parties: '),writeln(Nb_parties),
write('Tps moyen par partie: '),writeln(Tps_moy),
write('NB victoires random: '),writeln(NewWin_random),
write('NB victoires alpha_beta: '),writeln(NewWin_min_max).

game_over_ia(Board) :- 
	win_min_max(Win_min_max), win_random(Win_random), nb_parties(Nb_parties),
	display_board(), count_in_row(Board, JoueurX, JoueurO), 
	New_nb_parties is Nb_parties+1, retract(nb_parties(Nb_parties)),assert(nb_parties(New_nb_parties)),
	((JoueurX>JoueurO, victory(x), NewWin_random is Win_random+1, retract(win_random(Win_random)),assert(win_random(NewWin_random))) ; 
	(JoueurX<JoueurO, victory(o), NewWin_minmax is Win_min_max+1, retract(win_min_max(Win_min_max)),assert(win_min_max(NewWin_minmax))); draw()), !.

start_play_ia(Player) :- board(Board), possible_to_play(Board, Player, Possible) , ((Possible = 'Y', play_ia(Player, Board)) ; (opposite(Player, OppositePlayer), possible_to_play(Board, OppositePlayer, OtherPossible), ((OtherPossible='Y', play_ia(OppositePlayer, Board)) ; game_over_ia(Board)))).

play_procedure_ia(Board, Player, R, C) :- (correct_move(Board, Player, R, C),reverse_elements(Board, Player, R, C),board(NewBoard), playMove(NewBoard, R, C, NewNewBoard, Player), applyIt(NewBoard,NewNewBoard), opposite(Player, NewPlayer), start_play_ia(NewPlayer))  ;start_play_ia(Player).

%Ajouter le prédicat pour jouer un coup avec alphabeta
play_ia(Player, Board) :- 
		%((Player=x, ia_minmax(Board,Player,3,2));ia_alpha_beta(Board,Player,3)).
		((Player=x, ia_random(Board, Player));ia_minmax(Board,Player,3,2)).

ia_random(Board, Player):- list_possible_correct_moves(Board, Player, CorrectMoves),liste_coordinates_correct_moves(CorrectMoves,R,C),play_procedure_ia(Board, Player, R, C).


ia_minmax(Board, Player,Depth,TypeEval):- min_max(Board,maxPlayer,Player,Depth,TypeEval,BestTriple),nth0(0,BestTriple,R),nth0(1,BestTriple,C), play_procedure_ia(Board, Player, R, C).

ia_alpha_beta(Board,Player,Depth):-
	getMoveAlphaBeta(Board,Player,Depth,BestMove),nth0(0,BestMove,R),nth0(1,BestMove,C),play_procedure_ia(Board,Player,R,C).

do_ten_game:-
	init_ia,init_ia,init_ia,init_ia,init_ia,init_ia,init_ia,init_ia,init_ia,init_ia.
	
do_fifty_game:-
	do_ten_game, do_ten_game, do_ten_game, do_ten_game, do_ten_game.

minmax_vs_alphabeta:-
	retractall(win_min_max(Win_min_max)), retractall(win_random(Win_random)),retractall(nb_parties(Nb_parties)),retractall(tps_depart(Tps_depart)),
	Win_min_max=0, Win_random=0,Nb_parties=0,
	assert(win_min_max(Win_min_max)), assert(win_random(Win_random)),assert(nb_parties(Nb_parties)),
	get_time(Tps_depart), assert(tps_depart(Tps_depart)),
	%init_ia,
	%do_ten_game,
	do_fifty_game.
	
