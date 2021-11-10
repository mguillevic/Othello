l :- launchOthello.
%Remplacer par le chemin absolu correspondant à board.pl
launchOthello :- consult('c:/Users/Ahmed/Documents/Prolog/Othello/board'), init.

c :- consultOthello.
consultOthello :- consult('c:/Users/Ahmed/Documents/Prolog/Othello/board').

t :- testHeuristic.
testHeuristic :- consult('c:/Users/Ahmed/Documents/Prolog/Othello/heuristics'), test(R).

s :- statHeuristic.
statHeuristic :- consult('c:/Users/Ahmed/Documents/Prolog/Othello/ia_duel'), minmax_vs_alphabeta.
