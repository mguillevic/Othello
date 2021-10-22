%la variable board contient notre plateau de jeu (les cases vides contiennent _ et les autres 'x' ou 'o' selon quel joueur a pose le pion)
:- dynamic board/1. 

%predicat appele pour lancer le jeu, il purge d'abord la memoire de l'ancien tableau, puis cree un nouveau plateau en posant les 4 premieres pieces (2 'x' et 2 'o' au milieu du plateau) puis donne la main au joueur x.
init :- retractall(board(Board)), length(Board,8), assertLength(Board), assert(board(Board)),playMove(Board, 4, 4, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 3, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 4, NewBoard, o), applyIt(Board,NewBoard), playMove(Board, 4, 3, NewBoard, o), applyIt(Board,NewBoard), play('x'), !.

%sert a recuperer le joueur suivant
opposite(x,o).
opposite(o,x).

%fonctions appelees pour initialiser la taille du tableau.
%assertLength([H|Q]) va donner une taille de 8 a la premiere ligne du tableau puis recursivement egalement donner une taille de 8 aux autres lignes.
assertLength([]).
assertLength([H|Q]) :- length(H,8), assertLength(Q).

%predicat qui fait joueur les joueurs. On affiche d'abord l'etat courant du plateau puis recupere la case ou le joueur veut poser sa piece. On distingue ensuite deux cas : si le coup est valide, on l'execute et donne la main a l'autre joueur, sinon on ne fait rien et redonne la main au joueur ayant essaye de jouer.
%%%il faut rajouter que s'il n'y a aucun coup possible pour le joueur 'Player', on donne la main a l'autre, et que si le jeu est fini (plateau plein ou les deux joueurs bloques), on termine l'execution en affichant le gagnant ou le draw avec les resultats
play(Player) :- display_board, board(Board), write('C'), char_code(Guillemet, 39), write(Guillemet), write('est le tour de '), write(Player), writeln(' :'), write('Ligne'), read(R), write('Colonne'), read(C), 
%distinction des cas coup valide et invalide
((correct_move(Board, Player, R, C), playMove(Board, R, C, NewBoard, Player), applyIt(Board,NewBoard), opposite(Player, NewPlayer), play(NewPlayer))  ;  play(Player)).

%sert a l'affichage des cases, si la case est vide, on affiche '-', sinon on affiche son contenu
printVal(V) :- var(V), write('-'), !.
printVal(V) :- write(V).

%pour chaque ligne, on appelle l'affichage de sa premiere case (qui va recursivement appeler l'affichage des cases suivantes), puis on saute une ligne et on appelle recursivement les autres lignes
display_row([]).
display_row([H|Q]) :-  display_char(H), writeln(''), display_row(Q).
display_char([]).
display_char([H|Q]) :-  printVal(H), display_char(Q).

%affichage du plateau
display_board :- cls, writeln('********'), board(Board), display_row(Board), writeln('********').
display_board(B) :- cls, writeln('********'), display_row(B), writeln('********').
cls :- write('').
%cls :- write('\e[H\e[2J').

%playMove met Player dans la case si elle est vide et applyIt fixe le changement dans la variable dynamique board
playMove(Board, Row, Column, NewBoard, Player) :- NewBoard=Board, get_element(NewBoard, Row, Column, Player).
applyIt(Board,NewBoard) :- retract(board(Board)), assert(board(NewBoard)).

%getElement met dans Val l'element de Board a la position {NbRow, NbCol}. Si Val est fixe et que la case du tableau est libre, Val va etre mise dans la case
%getRow est similaire a getElement mais pour une ligne complete
get_element(Board, NbRow, NbCol, Val) :- nth0(NbRow,Board,Row), nth0(NbCol,Row,Val).
get_row(Board, NbRow, Row) :- nth0(NbRow,Board,Row).

%similaire a getElement mais ne modifie pas le plateau si val est fixee et pas la case. Elle peut neanmoins modifier Val si elle n'est pas fixee
compare_element(Board, Val, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Var), nonvar(Var), get_element(Board, NbRow, NbCol, Val).

%correctMove sert a savoir si on peut jouer dans une case specifique en respectant les regles. Il faut que dans au moins une des huit directions, il faut qu'il y ait une suite d'au moins un pion oppose avec au bout un element identique. Cela correspond a la premiere suite de 'or' (';'). Ensuite, il faut que si le coup soit valide, toutes les suites de pions verifiant la condition soient transformes en le pion du dernier joueur. Il s'agit de la derniere suite de 'et'. Pour chacune des directions, si la condition est validee, on modifie les pions.
correct_move(Board, Player, NbRow, NbCol) :- NbRowPrec is NbRow-1, NbRowSuiv is NbRow+1, NbColPrec is NbCol-1, NbColSuiv is NbCol+1, NbRowPrecPrec is NbRow-2, NbColPrecPrec is NbCol-2, NbRowSuivSuiv is NbRow+2, NbColSuivSuiv is NbCol+2, opposite(Player, Opposite), 
((compare_element(Board, Opposite, NbRowPrec, NbColPrec), correct_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec));
(compare_element(Board, Opposite, NbRowPrec, NbCol), correct_haut(Board, Player, NbRowPrecPrec, NbCol));
(compare_element(Board, Opposite, NbRowPrec, NbColSuiv), correct_diag_haut_droit(Board, Player, NbRowPrecPrec, NbColSuivSuiv));
(compare_element(Board, Opposite, NbRow, NbColPrec), correct_gauche(Board, Player, NbRow, NbColPrecPrec));
(compare_element(Board, Opposite, NbRow, NbColSuiv), correct_droit(Board, Player, NbRow, NbColSuivSuiv));
(compare_element(Board, Opposite, NbRowSuiv, NbColPrec), correct_diag_bas_gauche(Board, Player, NbRowSuivSuiv, NbColPrecPrec));
(compare_element(Board, Opposite, NbRowSuiv, NbCol), correct_bas(Board, Player, NbRowSuivSuiv, NbCol));
(compare_element(Board, Opposite, NbRowSuiv, NbColSuiv), correct_diag_bas_droit(Board, Player, NbRowSuivSuiv, NbColSuivSuiv))),

(compare_element(Board, Opposite, NbRowPrec, NbColPrec), correct_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec), modify_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec)),
(compare_element(Board, Opposite, NbRowPrec, NbCol), correct_haut(Board, Player, NbRowPrecPrec, NbCol), modify_haut(Board, Player, NbRowPrecPrec, NbColPrecPrec)),
(compare_element(Board, Opposite, NbRowPrec, NbColSuiv), correct_diag_haut_droit(Board, Player, NbRowPrecPrec, NbColSuivSuiv), modify_diag_haut_droit(Board, Player, NbRowPrecPrec, NbColPrecPrec)),
(compare_element(Board, Opposite, NbRow, NbColPrec), correct_gauche(Board, Player, NbRow, NbColPrecPrec), modify_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec)),
(compare_element(Board, Opposite, NbRow, NbColSuiv), correct_droit(Board, Player, NbRow, NbColSuivSuiv), modify_droit(Board, Player, NbRowPrecPrec, NbColPrecPrec)),
(compare_element(Board, Opposite, NbRowSuiv, NbColPrec), correct_diag_bas_gauche(Board, Player, NbRowSuivSuiv, NbColPrecPrec), modify_diag_bas_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec)),
(compare_element(Board, Opposite, NbRowSuiv, NbCol), correct_bas(Board, Player, NbRowSuivSuiv, NbCol), modify_bas(Board, Player, NbRowPrecPrec, NbColPrecPrec)),
(compare_element(Board, Opposite, NbRowSuiv, NbColSuiv), correct_diag_bas_droit(Board, Player, NbRowSuivSuiv, NbColSuivSuiv), modify_diag_bas_droit(Board, Player, NbRowPrecPrec, NbColPrecPrec))
. 



correct_diag_haut_gauche(Board, Player, -1, _) :- fail.
correct_diag_haut_gauche(Board, Player, _, -1) :- fail.
correct_diag_haut_gauche(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowPrec is NbRow-1, NbColPrec is NbCol-1, correct_diag_haut_gauche(Board, Player, NbRowPrec, NbColPrec))).

correct_diag_haut_droit(Board, Player, -1, _) :- fail.
correct_diag_haut_droit(Board, Player, _, 8) :- fail.
correct_diag_haut_droit(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowPrec is NbRow-1, NbColSuiv is NbCol+1, correct_diag_haut_droit(Board, Player, NbRowPrec, NbColSuiv))).

correct_diag_bas_gauche(Board, Player, 8, _) :- fail.
correct_diag_bas_gauche(Board, Player, _, -1) :- fail.
correct_diag_bas_gauche(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowSuiv is NbRow+1, NbColPrec is NbCol-1, correct_diag_bas_gauche(Board, Player, NbRowSuiv, NbColPrec))).

correct_diag_bas_droit(Board, Player, 8, _) :- fail.
correct_diag_bas_droit(Board, Player, _, 8) :- fail.
correct_diag_bas_droit(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowSuiv is NbRow+1, NbColSuiv is NbCol+1, correct_diag_bas_droit(Board, Player, NbRowSuiv, NbColSuiv))).

correct_haut(Board, Player, -1, _) :- fail.
correct_haut(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowPrec is NbRow-1, correct_haut(Board, Player, NbRowPrec, NbCol))).

correct_bas(Board, Player, 8, _) :- fail.
correct_bas(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowSuiv is NbRow+1, correct_bas(Board, Player, NbRowSuiv, NbCol))).

correct_gauche(Board, Player, _, -1) :- fail.
correct_gauche(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbColPrec is NbCol-1, correct_gauche(Board, Player, NbRow, NbColPrec))).

correct_droit(Board, Player, _, 8) :- fail.
correct_droit(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbColSuiv is NbCol+1, correct_droit(Board, Player, NbRow, NbColSuiv))).

modify_diag_haut_gauche(Board, Player, -1, _) :- fail.
modify_diag_haut_gauche(Board, Player, _, -1) :- fail.
modify_diag_haut_gauche(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowPrec is NbRow-1, NbColPrec is NbCol-1, correct_diag_haut_gauche(Board, Player, NbRowPrec, NbColPrec))). %a finir, ajouter un forcePut