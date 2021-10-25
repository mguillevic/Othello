%la variable board contient notre plateau de jeu (les cases vides contiennent _ et les autres 'x' ou 'o' selon quel joueur a pose le pion)
:- dynamic board/1. 

%predicat appele pour lancer le jeu, il purge d'abord la memoire de l'ancien tableau, puis cree un nouveau plateau en posant les 4 premieres pieces (2 'x' et 2 'o' au milieu du plateau) puis donne la main au joueur x.
init :- retractall(board(Board)), length(Board,8), assertLength(Board), assert(board(Board)),playMove(Board, 4, 4, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 3, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 4, NewBoard, o), applyIt(Board,NewBoard), playMove(Board, 4, 3, NewBoard, o), applyIt(Board,NewBoard), playMove(Board, 2, 3, NewBoard, o), applyIt(Board,NewBoard), playMove(Board, 2, 2, NewBoard, x), applyIt(Board,NewBoard), play('x'), !.

%sert a recuperer le joueur suivant
opposite(x,o).
opposite(o,x).

%fonctions appelees pour initialiser la taille du tableau.
%assertLength([H|Q]) va donner une taille de 8 a la premiere ligne du tableau puis recursivement egalement donner une taille de 8 aux autres lignes.
assertLength([]).
assertLength([H|Q]) :- length(H,8), assertLength(Q).

%predicat qui fait joueur les joueurs. On affiche d'abord l'etat courant du plateau puis recupere la case ou le joueur veut poser sa piece. On distingue ensuite deux cas : si le coup est valide, on l'execute et donne la main a l'autre joueur, sinon on ne fait rien et redonne la main au joueur ayant essaye de jouer.
%%%il faut rajouter que s'il n'y a aucun coup possible pour le joueur 'Player', on donne la main a l'autre, et que si le jeu est fini (plateau plein ou les deux joueurs bloques), on termine l'execution en affichant le gagnant ou le draw avec les resultats
play(Player) :- display_board(Player), board(Board), write('C'), char_code(Guillemet, 39), write(Guillemet), write('est le tour de '), write(Player), writeln(' :'), write('Ligne'), read(R), write('Colonne'), read(C), 
%distinction des cas coup valide et invalide
((correct_move(Board, Player, R, C), reverse_elements(Board, Player, R, C), board(NewBoard), playMove(NewBoard, R, C, NewNewBoard, Player), applyIt(NewBoard,NewNewBoard), opposite(Player, NewPlayer), play(NewPlayer))  ;  play(Player)).

%sert a l'affichage des cases, si la case est vide, on affiche '-', sinon on affiche son contenu
printVal(V, Color) :- var(V), ansi_format([bold,Color], '-', []), !.
printVal(V, Color) :- ansi_format([bold,Color], '~w', V).
printVal(V) :- var(V), write('-'), !.
printVal(V) :- write(V).

%pour chaque ligne, on appelle l'affichage de sa premiere case (qui va recursivement appeler l'affichage des cases suivantes), puis on saute une ligne et on appelle recursivement les autres lignes. Le premier appel a la ligne affiche 0 puis chaque nouveau appel affiche 1 de plus
display_row([], _, _).
display_row([H|Q], Player, NbRow) :-  write(NbRow), display_char(H, Player, NbRow, 0), writeln(''), NextNbRow is NbRow+1, display_row(Q, Player, NextNbRow).
display_char([], _, _, _).
display_char([H|Q], Player, NbRow, NbCol) :-  ((board(Board), correct_move(Board, Player, NbRow, NbCol), printVal(H, fg(cyan)));printVal(H)), NextNbCol is NbCol+1, display_char(Q, Player, NbRow, NextNbCol).

%affichage du plateau
display_board(Player) :- cls, writeln('********'), writeln(' 01234567'), board(Board), display_row(Board, Player, 0), writeln('********').
display_board(B, Player) :- cls, writeln('********'), writeln(' 01234567'), display_row(B, Player, 0), writeln('********').
cls :- true.
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
correct_move(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), var(Val), NbRowPrec is NbRow-1, NbRowSuiv is NbRow+1, NbColPrec is NbCol-1, NbColSuiv is NbCol+1, NbRowPrecPrec is NbRow-2, NbColPrecPrec is NbCol-2, NbRowSuivSuiv is NbRow+2, NbColSuivSuiv is NbCol+2, opposite(Player, Opposite), 
((compare_element(Board, Opposite, NbRowPrec, NbColPrec), correct_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec));
(compare_element(Board, Opposite, NbRowPrec, NbCol), correct_haut(Board, Player, NbRowPrecPrec, NbCol));
(compare_element(Board, Opposite, NbRowPrec, NbColSuiv), correct_diag_haut_droit(Board, Player, NbRowPrecPrec, NbColSuivSuiv));
(compare_element(Board, Opposite, NbRow, NbColPrec), correct_gauche(Board, Player, NbRow, NbColPrecPrec));
(compare_element(Board, Opposite, NbRow, NbColSuiv), correct_droit(Board, Player, NbRow, NbColSuivSuiv));
(compare_element(Board, Opposite, NbRowSuiv, NbColPrec), correct_diag_bas_gauche(Board, Player, NbRowSuivSuiv, NbColPrecPrec));
(compare_element(Board, Opposite, NbRowSuiv, NbCol), correct_bas(Board, Player, NbRowSuivSuiv, NbCol));
(compare_element(Board, Opposite, NbRowSuiv, NbColSuiv), correct_diag_bas_droit(Board, Player, NbRowSuivSuiv, NbColSuivSuiv))).

reverse_elements(Board, Player, NbRow, NbCol) :- NbRowPrec is NbRow-1, NbRowSuiv is NbRow+1, NbColPrec is NbCol-1, NbColSuiv is NbCol+1, NbRowPrecPrec is NbRow-2, NbColPrecPrec is NbCol-2, NbRowSuivSuiv is NbRow+2, NbColSuivSuiv is NbCol+2, opposite(Player, Opposite), 
((compare_element(Board, Opposite, NbRowPrec, NbColPrec), correct_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec), modify_diag_haut_gauche(Board, Player, NbRowPrec, NbColPrec, NewBoard), applyIt(Board, NewBoard));true),
((board(Board2), compare_element(Board, Opposite, NbRowPrec, NbCol), correct_haut(Board, Player, NbRowPrecPrec, NbCol), modify_haut(Board2, Player, NbRowPrec, NbCol, NewBoard2), applyIt(Board2, NewBoard2));true),
((board(Board3), compare_element(Board, Opposite, NbRowPrec, NbColSuiv), correct_diag_haut_droit(Board, Player, NbRowPrecPrec, NbColSuivSuiv), modify_diag_haut_droit(Board3, Player, NbRowPrec, NbColSuiv, NewBoard3), applyIt(Board3, NewBoard3));true),
((board(Board4), compare_element(Board, Opposite, NbRow, NbColPrec), correct_gauche(Board, Player, NbRow, NbColPrecPrec), modify_gauche(Board4, Player, NbRow, NbColPrec, NewBoard4), applyIt(Board4, NewBoard4));true),
((board(Board5), compare_element(Board, Opposite, NbRow, NbColSuiv), correct_droit(Board, Player, NbRow, NbColSuivSuiv), modify_droit(Board5, Player, NbRow, NbColSuiv, NewBoard5), applyIt(Board5, NewBoard5));true),
((board(Board6), compare_element(Board, Opposite, NbRowSuiv, NbColPrec), correct_diag_bas_gauche(Board, Player, NbRowSuivSuiv, NbColPrecPrec), modify_diag_bas_gauche(Board6, Player, NbRowSuiv, NbColPrec, NewBoard6), applyIt(Board6, NewBoard6));true),
((board(Board7), compare_element(Board, Opposite, NbRowSuiv, NbCol), correct_bas(Board, Player, NbRowSuivSuiv, NbCol), modify_bas(Board7, Player, NbRowSuiv, NbCol, NewBoard7), applyIt(Board7, NewBoard7));true),
((board(Board8), compare_element(Board, Opposite, NbRowSuiv, NbColSuiv), correct_diag_bas_droit(Board, Player, NbRowSuivSuiv, NbColSuivSuiv), modify_diag_bas_droit(Board8, Player, NbRowSuiv, NbColSuiv, NewBoard8), applyIt(Board8, NewBoard8));true)
. 

%la diagonale qui va vers le haut a gauche respecte le critere de placement si on trouve un pion de meme couleur avant la fin ou de trouver un vide (le premier pion de couleur differente a deja ete teste avant). Si on sort du tableau (col -1 ou lig -1), ou si un element est variable, alors la condition n'est pas respectee et on sort. Ainsi on verifie jusqu'a -1 lig ou -1 col quel est le pion actuel, s'il est variable (vide), on renvoie faux, s'il est identique au player on renvoie true, et s'il est de la couleur opposee on conyinue de chercher recursivement sur la diagonale.
%la logique est la meme pour les 7 autres directions
correct_diag_haut_gauche(_, _, -1, _) :- fail.
correct_diag_haut_gauche(_, _, _, -1) :- fail.
correct_diag_haut_gauche(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowPrec is NbRow-1, NbColPrec is NbCol-1, correct_diag_haut_gauche(Board, Player, NbRowPrec, NbColPrec))).

correct_diag_haut_droit(_, _, -1, _) :- fail.
correct_diag_haut_droit(_, _, _, 8) :- fail.
correct_diag_haut_droit(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowPrec is NbRow-1, NbColSuiv is NbCol+1, correct_diag_haut_droit(Board, Player, NbRowPrec, NbColSuiv))).

correct_diag_bas_gauche(_, _, 8, _) :- fail.
correct_diag_bas_gauche(_, _, _, -1) :- fail.
correct_diag_bas_gauche(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowSuiv is NbRow+1, NbColPrec is NbCol-1, correct_diag_bas_gauche(Board, Player, NbRowSuiv, NbColPrec))).

correct_diag_bas_droit(_, _, 8, _) :- fail.
correct_diag_bas_droit(_, _, _, 8) :- fail.
correct_diag_bas_droit(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowSuiv is NbRow+1, NbColSuiv is NbCol+1, correct_diag_bas_droit(Board, Player, NbRowSuiv, NbColSuiv))).

correct_haut(_, _, -1, _) :- fail.
correct_haut(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowPrec is NbRow-1, correct_haut(Board, Player, NbRowPrec, NbCol))).

correct_bas(_, _, 8, _) :- fail.
correct_bas(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbRowSuiv is NbRow+1, correct_bas(Board, Player, NbRowSuiv, NbCol))).

correct_gauche(_, _, _, -1) :- fail.
correct_gauche(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbColPrec is NbCol-1, correct_gauche(Board, Player, NbRow, NbColPrec))).

correct_droit(_, _, _, 8) :- fail.
correct_droit(Board, Player, NbRow, NbCol) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), (compare_element(Board, Player, NbRow, NbCol) ; (NbColSuiv is NbCol+1, correct_droit(Board, Player, NbRow, NbColSuiv))).

%Pour remplacer un element dans un tableau, on cherche d'abord la ligne ou l'on veut effectuer le changement. Pour ce faire, on cherche recursivement la ligne suivante et decrementant un compteur et stockant les lignes precedentes dans le nouveau tableau. Lorsque le compteur arrive a 0, on modifie la ligne en question et on la met dans le nouveau tableau avec le reste de l'ancien. La modification de la ligne est effectuee avec le predicat remplacer_in_row. Le dernier predicat remplacer sert en cas de depassement de limites.
remplacer([T|Q], 0, NbCol, ElementToAdd, [NewRow|Q]) :- remplacer_in_row(T, NbCol, ElementToAdd, NewRow).
remplacer([T|Q], NbRow, NbCol, ElementToAdd, [T|R]):- NbRow > -1, NbCol > -1, NextNbRow is NbRow-1, remplacer(Q, NextNbRow, NbCol, ElementToAdd, R), !.
remplacer(L, _, _, _, L).

%Pour remplacer un element dans une ligne, on cherche le numero de la colonne ou l'on veut effectuer le changement. Pour ce faire, on cherche recursivement la case suivante et decrementant un compteur et stockant les cases precedentes dans la nouvelle ligne. Lorsque le compteur arrive a 0, on modifie la case en question et on la met dans la nouvelle ligne avec le reste de l'ancienne. Le dernier predicat remplacer_in_row sert en cas de depassement de limites.
remplacer_in_row([_|Q], 0, ElementToAdd, [ElementToAdd|Q]).
remplacer_in_row([T|Q], NbCol, ElementToAdd, [T|R]):- NbCol > -1, NextNbCol is NbCol-1, remplacer_in_row(Q, NextNbCol, ElementToAdd, R), !.
remplacer_in_row(L, _, _, L).

%Pour retourner une ligne (ou diagonale), on va utiliser une logique similaire a la verification de la contrainte d'entourage. On va parcourir jusqu'a la case ou on retrouve le pion du joueur en modifiant tous les pions adverses trouves en pions du joueur. Pour ce faire on cree un nouveau tableau avec a l'interieur le premier pion de la diagonale modifie, puis on le passe en parametre de l'appel recursif au suivant. Le suivant va ensuite creer un autre tableau en prenant ce parametre comme base et va modifier son pion, et ainsi de suite. Lorsque l'on arrive au dernier pion a modifier, on va renvoyer le bon tableau (cad avec tous les pions adverses retournes) en cascade jusqu'au premier appel.
modify_diag_haut_gauche(_, _, -1, _, _) :- fail.
modify_diag_haut_gauche(_, _, _, -1, _) :- fail.
modify_diag_haut_gauche(Board, Player, NbRow, NbCol, NewNewBoard) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), ((compare_element(Board, Player, NbRow, NbCol), remplacer(Board, NbRow, NbCol, Player, NewNewBoard)) ; (NbRowPrec is NbRow-1, NbColPrec is NbCol-1, remplacer(Board, NbRow, NbCol, Player, NewBoard), modify_diag_haut_gauche(NewBoard, Player, NbRowPrec, NbColPrec, NewNewBoard))).

modify_diag_bas_gauche(_, _, 8, _, _) :- fail.
modify_diag_bas_gauche(_, _, _, -1, _) :- fail.
modify_diag_bas_gauche(Board, Player, NbRow, NbCol, NewNewBoard) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), ((compare_element(Board, Player, NbRow, NbCol), remplacer(Board, NbRow, NbCol, Player, NewNewBoard)) ; (NbRowSuiv is NbRow+1, NbColPrec is NbCol-1, remplacer(Board, NbRow, NbCol, Player, NewBoard), modify_diag_bas_gauche(NewBoard, Player, NbRowSuiv, NbColPrec, NewNewBoard))).

modify_diag_haut_droit(_, _, -1, _, _) :- fail.
modify_diag_haut_droit(_, _, _, 8, _) :- fail.
modify_diag_haut_droit(Board, Player, NbRow, NbCol, NewNewBoard) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), ((compare_element(Board, Player, NbRow, NbCol), remplacer(Board, NbRow, NbCol, Player, NewNewBoard)) ; (NbRowPrec is NbRow-1, NbColSuiv is NbCol+1, remplacer(Board, NbRow, NbCol, Player, NewBoard), modify_diag_haut_droit(NewBoard, Player, NbRowPrec, NbColSuiv, NewNewBoard))).

modify_diag_bas_droit(_, _, -1, _, _) :- fail.
modify_diag_bas_droit(_, _, _, -1, _) :- fail.
modify_diag_bas_droit(Board, Player, NbRow, NbCol, NewNewBoard) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), ((compare_element(Board, Player, NbRow, NbCol), remplacer(Board, NbRow, NbCol, Player, NewNewBoard)) ; (NbRowSuiv is NbRow+1, NbColSuiv is NbCol+1, remplacer(Board, NbRow, NbCol, Player, NewBoard), modify_diag_bas_droit(NewBoard, Player, NbRowSuiv, NbColSuiv, NewNewBoard))).

modify_haut(_, _, -1, _, _) :- fail.
modify_haut(Board, Player, NbRow, NbCol, NewNewBoard) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), ((compare_element(Board, Player, NbRow, NbCol), remplacer(Board, NbRow, NbCol, Player, NewNewBoard)) ; (NbRowPrec is NbRow-1, remplacer(Board, NbRow, NbCol, Player, NewBoard), modify_haut(NewBoard, Player, NbRowPrec, NbCol, NewNewBoard))).

modify_bas(_, _, 8, _, _) :- fail.
modify_bas(Board, Player, NbRow, NbCol, NewNewBoard) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), ((compare_element(Board, Player, NbRow, NbCol), remplacer(Board, NbRow, NbCol, Player, NewNewBoard)) ; (NbRowSuiv is NbRow+1, remplacer(Board, NbRow, NbCol, Player, NewBoard), modify_bas(NewBoard, Player, NbRowSuiv, NbCol, NewNewBoard))).

modify_droit(_, _, _, 8, _) :- fail.
modify_droit(Board, Player, NbRow, NbCol, NewNewBoard) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), ((compare_element(Board, Player, NbRow, NbCol), remplacer(Board, NbRow, NbCol, Player, NewNewBoard)) ; (NbColSuiv is NbCol+1, remplacer(Board, NbRow, NbCol, Player, NewBoard), modify_droit(NewBoard, Player, NbRow, NbColSuiv, NewNewBoard))).

modify_gauche(_, _, _, -1, _) :- fail.
modify_gauche(Board, Player, NbRow, NbCol, NewNewBoard) :- get_element(Board, NbRow, NbCol, Val), nonvar(Val), ((compare_element(Board, Player, NbRow, NbCol), remplacer(Board, NbRow, NbCol, Player, NewNewBoard)) ; (NbColPrec is NbCol-1, remplacer(Board, NbRow, NbCol, Player, NewBoard), modify_gauche(NewBoard, Player, NbRow, NbColPrec, NewNewBoard))).

%liste tous les coups possible d'un joueur dans un tableau avec 'Y' la ou il peut jouer et 'N' dans le reste. Pour chaque ligne, on appelle le predicat de recherche pour la premiere case puis on appelle recursivement la ligne suivante. Pour chaque case, on regarde si le coup est possible et on le stock dans le tableau puis on regarde recurssivement pour le suivant.
list_possible_correct_moves(Board, Player, CorrectMoves) :- list_possible_correct_moves_row(Board, Player, 0, CorrectMoves).

list_possible_correct_moves_box(_, _, NbRow, 8, []) :- NbRow > -1.
list_possible_correct_moves_box(Board, Player, NbRow, NbCol, [T|Q]) :- NbRow > -1, NbCol > -1, ((correct_move(Board, Player, NbRow, NbCol), T='Y') ; T='N'), NbColSuiv is NbCol + 1, list_possible_correct_moves_box(Board, Player, NbRow, NbColSuiv, Q).
list_possible_correct_moves_box(_, _, _, _, []).

list_possible_correct_moves_row(_, _, 8, []).
list_possible_correct_moves_row(Board, Player, NbRow, [T|Q]) :- NbRow > -1, list_possible_correct_moves_box(Board, Player, NbRow, 0, T), NextNbRow is NbRow+1, list_possible_correct_moves_row(Board, Player, NextNbRow, Q).
list_possible_correct_moves_row(_, _, _, []).