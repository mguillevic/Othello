%Remplacer le path suivant par le chemin absolu correspondant à board.pl sur votre ordinateur
path('c:/Users/Ahmed/Documents/Prolog/Othello/board').

l :- launchOthello.
launchOthello :- consultOthello, init.

c :- consultOthello.
consultOthello :- path(Path), consult(Path).
