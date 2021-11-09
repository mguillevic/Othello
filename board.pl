:- consult(heuristics).

%la variable board contient notre plateau de jeu (les cases vides contiennent _ et les autres 'x' ou 'o' selon quel joueur a pose le pion)
:- dynamic board/1.
%la variable choix contient le mode de jeu que le joueur souhaite (match avec quelqu'un ou heuristique VS heuristique)
:- dynamic choix1/1.
:- dynamic choix2/1.
% la variable profondeur contient la profondeur exploree dans l'arbre
% de recherche des coups possibles pour l'heuristique min_max que le
% joueur souhaite (match avec quelqu'un ou heuristique VS heuristique)
:- dynamic profondeur1/1.
:- dynamic profondeur2/1.
% la variable duel contient le mode de jeu (joueur contre joueur, ia
% contre ia, joueur contre ia)
:- dynamic duel/1.
% la variable pion contient le symbole x ou y du joueur autre que l'ia
:- dynamic pion/1.


:-consult(heuristics).

%predicat appele pour lancer le jeu, il purge d'abord la memoire de l'ancien tableau, puis cree un nouveau plateau en posant les 4 premieres pieces (2 'x' et 2 'o' au milieu du plateau) puis donne la main au joueur x.
init :- retractall(board(Board)), game_mode(), length(Board,8), assertLength(Board), assert(board(Board)),playMove(Board, 4, 4, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 3, NewBoard, x), applyIt(Board,NewBoard), playMove(Board, 3, 4, NewBoard, o), applyIt(Board,NewBoard), playMove(Board, 4, 3, NewBoard, o), applyIt(Board,NewBoard), start_play('x'), !.

%
game_mode() :- 

retractall(choix1(Choix)),retractall(choix2(Choix)),retractall(profondeur1(Profondeur)),retractall(profondeur2(Profondeur)),retractall(duel(Duel)),retractall(pion(Pion)),char_code(Guillemet, 39),
writeln('Voulez vous jouer contre un autre joueur (1.) ou contre une ia (2.) ou voir un duel entre ia (3.)'),
read(Duel),assert(duel(Duel)),
(
(Duel=1,Choix1='duel',assert(choix1(Choix1)),assert(choix2(Choix1)));
(Duel=2,write('Choix de l'),write(Guillemet),write('heuristique :'), writeln('Random -> random.'),writeln('min et max -> min_max.'), read(Choix1), assert(choix1(Choix1)),Choix2=Choix1, assert(choix2(Choix2)), (write('Voulez-vous jouer avec x ou o?'),read(Pion),assert(pion(Pion)),(Choix1='min_max',write('Choix du niveau (facile/moyen/difficile)'),read(Difficulte),((Difficulte='facile',Profondeur=2);(Difficulte='difficile',Profondeur=5);(Difficulte='moyen',Profondeur=4)),assert(profondeur1(Profondeur)),assert(profondeur2(Profondeur)));(Choix1='random')));
(Duel=3,Pion='x',assert(pion(Pion)),write('Choix de l'),write(Guillemet),write('heuristique 1 :'), writeln('Random -> random.'),writeln('min et max -> min_max.'), read(Choix1), assert(choix1(Choix1)),write('Choix de l'),write(Guillemet),write('heuristique 2 :'), writeln('Random -> random.'),writeln('min et max -> min_max.'), read(Choix2), assert(choix2(Choix2)), ((Choix1='min_max',write('Choix du niveau pour le 1 (facile/moyen/difficile)'),read(Difficulte1),((Difficulte1='facile',Profondeur1=2);(Difficulte1='difficile',Profondeur1=5);(Difficulte1='moyen',Profondeur1=4)),assert(profondeur1(Profondeur1)));true), ((Choix2='min_max',write('Choix du niveau pour le 2 (facile/moyen/difficile)'),read(Difficulte2),((Difficulte2='facile',Profondeur2=2);(Difficulte2='difficile',Profondeur2=5);(Difficulte2='moyen',Profondeur2=4)),assert(profondeur2(Profondeur2)));true))
).

%sert a recuperer le joueur suivant
opposite(x,o).
opposite(o,x).

%fonctions appelees pour initialiser la taille du tableau.
%assertLength([H|Q]) va donner une taille de 8 a la premiere ligne du tableau puis recursivement egalement donner une taille de 8 aux autres lignes.
assertLength([]).
assertLength([H|Q]) :- length(H,8), assertLength(Q).

%si la methode recoit le caractere d'arret (ici 'a'), on reussi le test, sinon il fail.
asking_for_exit(a) :- true.
asking_for_exit(_) :- fail.

draw() :- writeln('Egalite !!! Bravo a tous les deux').
victory(Player) :- write('Bravo, le joueur '), write(Player), writeln(' a gagne !!!').

%affiche le plateau, compte le nombre de pions poses par joueur puis annonce la fin de la partie
game_over(Board) :- display_board(), count_in_row(Board, JoueurX, JoueurO), ((JoueurX>JoueurO, victory(x)) ; (JoueurX<JoueurO, victory(o)) ; draw()), !.

%predicat test si le joueur peut jouer ou non, si oui on continue la procedure du tour, sinon on donne la main a l'autre joueur. Si aucun des deux joueurs ne peut jouer, la partie est terminee.
start_play(Player) :- board(Board), possible_to_play(Board, Player, Possible) , ((Possible = 'Y', play(Player, Board)) ; (opposite(Player, OppositePlayer), possible_to_play(Board, OppositePlayer, OtherPossible), ((OtherPossible='Y', play(OppositePlayer, Board)) ; game_over(Board)))).

%predicat qui fait joueur les joueurs. On affiche d'abord l'etat courant du plateau puis appel la suite de la methode de jeu.
play(Player, Board) :- display_board(Player),choix1(Choix1),choix2(Choix2), ((Choix1='duel',lis(Board, Player));(duel(Duel),pion(Pion),(Duel=2, Pion=Player,lis(Board, Player));(Player=Pion,Choix1='random',lis_random(Board, Player));(Player=Pion,Choix1='min_max',lis_minmax(Board, Player));(Choix2='random',lis_random(Board, Player));(Choix2='min_max',lis_minmax(Board, Player)))).

%Dans la suite de la methode de jeu, on recupere la case ou le joueur veut poser sa piece. Si apres l'entree de la ligne ou de la colonne, on recoit le caractere d'arret, on ne poursuit pas la fin de la methode et le jeu s'arrete.
lis(Board, Player) :- write('C'), char_code(Guillemet, 39), write(Guillemet), write('est le tour de '), write(Player), writeln(' :'), write('Ligne'), read(R), (asking_for_exit(R) ; (write('Colonne'), read(C), (asking_for_exit(C) ; play_procedure(Board, Player, R, C)))).

% Dans la suite de la methode de jeu, on recupere la case decidee par l'heuristique random. Si apres l'entree de la ligne ou de la colonne, on recoit le caractere d'arret, on ne poursuit pas la fin de la methode et le jeu s'arrete.
lis_random(Board, Player):- duel(Duel), write('random joue '), write(Player), writeln(' :'), (Duel=3, write('Continuer a jouer? (y/a)'),read(Reponse)), (Duel=3, asking_for_exit(Reponse));(list_possible_correct_moves(Board, Player, CorrectMoves),liste_coordinates_correct_moves(CorrectMoves,R,C),play_procedure(Board, Player, R, C)).

% Dans la suite de la methode de jeu, on recupere la case decidee par l'heuristique min max. Si apres l'entree de la ligne ou de la colonne, on recoit le caractere d'arret, on ne poursuit pas la fin de la methode et le jeu s'arrete.
lis_minmax(Board, Player):- duel(Duel),write('min_max joue '), write(Player), writeln(' :'), (Duel=3, write('Continuer a jouer? (y/a)'),read(Reponse)), (Duel=3, asking_for_exit(Reponse)); ( ((pion(Pion), Pion=Player,profondeur1(Profondeur));profondeur2(Profondeur)), write('Profondeur de '), writeln(Profondeur), min_max(Board,maxPlayer,Player,Profondeur,1,BestTriple),nth0(0,BestTriple,R),nth0(1,BestTriple,C),play_procedure(Board, Player, R, C)).

%Dans la fin de la methode de jeu, on distingue deux cas : si le coup est valide, on l'execute et donne la main a l'autre joueur, sinon on ne fait rien et redonne la main au joueur ayant essaye de jouer.
play_procedure(Board, Player, R, C) :- (correct_move(Board, Player, R, C),reverse_elements(Board, Player, R, C),board(NewBoard), playMove(NewBoard, R, C, NewNewBoard, Player), applyIt(NewBoard,NewNewBoard), opposite(Player, NewPlayer), start_play(NewPlayer))  ;start_play(Player).

%sert a l'affichage des cases, si la case est vide, on affiche '-', sinon on affiche son contenu
printVal(V, Color) :- var(V), ansi_format([bold,Color], '-', []), !.
printVal(V, Color) :- ansi_format([bold,Color], '~w', V).
printVal(V) :- var(V), write('-'), !.
printVal(V) :- write(V).

%pour chaque ligne, on appelle l'affichage de sa premiere case (qui va recursivement appeler l'affichage des cases suivantes), puis on saute une ligne et on appelle recursivement les autres lignes. Le premier appel a la ligne affiche 0 puis chaque nouveau appel affiche 1 de plus. A chaque appel d'affichage de case, s'il s'agit d'un jeu possible (correct) pour Player, on l'affiche en bleu.
display_row([], _, _).
display_row([H|Q], Player, NbRow) :-  write(NbRow), display_char(H, Player, NbRow, 0), writeln(''), NextNbRow is NbRow+1, display_row(Q, Player, NextNbRow).
display_char([], _, _, _).
display_char([H|Q], Player, NbRow, NbCol) :-  ((board(Board), correct_move(Board, Player, NbRow, NbCol), printVal(H, fg(cyan)));printVal(H)), NextNbCol is NbCol+1, display_char(Q, Player, NbRow, NextNbCol).

display_row([], _).
display_row([H|Q], NbRow) :-  write(NbRow), display_char(H, NbRow, 0), writeln(''), NextNbRow is NbRow+1, display_row(Q, NextNbRow).
display_char([], _, _).
display_char([H|Q], NbRow, NbCol) :-  printVal(H), NextNbCol is NbCol+1, display_char(Q, NbRow, NextNbCol).

%affichage du plateau
display_board() :- writeln('********'), writeln(' 01234567'), board(Board), display_row(Board, 0), writeln('********').
display_board(Player) :- writeln('********'), writeln(' 01234567'), board(Board), display_row(Board, Player, 0), writeln('********').
display_board(B, Player) :-  writeln('********'), writeln(' 01234567'), display_row(B, Player, 0), writeln('********').
%cls :- true.
cls :- write('\e[H\e[2J').

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

reverse_elements(Board, Player, NbRow, NbCol,NewBoard8) :- NbRowPrec is NbRow-1, NbRowSuiv is NbRow+1, NbColPrec is NbCol-1, NbColSuiv is NbCol+1, NbRowPrecPrec is NbRow-2, NbColPrecPrec is NbCol-2, NbRowSuivSuiv is NbRow+2, NbColSuivSuiv is NbCol+2, opposite(Player, Opposite),
((compare_element(Board, Opposite, NbRowPrec, NbColPrec), correct_diag_haut_gauche(Board, Player, NbRowPrecPrec, NbColPrecPrec), modify_diag_haut_gauche(Board, Player, NbRowPrec, NbColPrec, NewBoard1));NewBoard1=Board),
((compare_element(Board, Opposite, NbRowPrec, NbCol), correct_haut(Board, Player, NbRowPrecPrec, NbCol), modify_haut(NewBoard1, Player, NbRowPrec, NbCol, NewBoard2));NewBoard2=NewBoard1),
((compare_element(Board, Opposite, NbRowPrec, NbColSuiv), correct_diag_haut_droit(Board, Player, NbRowPrecPrec, NbColSuivSuiv), modify_diag_haut_droit(NewBoard2, Player, NbRowPrec, NbColSuiv, NewBoard3));NewBoard3=NewBoard2),
((compare_element(Board, Opposite, NbRow, NbColPrec), correct_gauche(Board, Player, NbRow, NbColPrecPrec), modify_gauche(NewBoard3, Player, NbRow, NbColPrec, NewBoard4));NewBoard4=NewBoard3),
((compare_element(Board, Opposite, NbRow, NbColSuiv), correct_droit(Board, Player, NbRow, NbColSuivSuiv), modify_droit(NewBoard4, Player, NbRow, NbColSuiv, NewBoard5));NewBoard5=NewBoard4),
((compare_element(Board, Opposite, NbRowSuiv, NbColPrec), correct_diag_bas_gauche(Board, Player, NbRowSuivSuiv, NbColPrecPrec), modify_diag_bas_gauche(NewBoard5, Player, NbRowSuiv, NbColPrec, NewBoard6));NewBoard6=NewBoard5),
((compare_element(Board, Opposite, NbRowSuiv, NbCol), correct_bas(Board, Player, NbRowSuivSuiv, NbCol), modify_bas(NewBoard6, Player, NbRowSuiv, NbCol, NewBoard7));NewBoard7=NewBoard6),
((compare_element(Board, Opposite, NbRowSuiv, NbColSuiv), correct_diag_bas_droit(Board, Player, NbRowSuivSuiv, NbColSuivSuiv), modify_diag_bas_droit(NewBoard7, Player, NbRowSuiv, NbColSuiv, NewBoard8));NewBoard8=NewBoard7).

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

%ce predicat sert a savoir si un joueur peut jouer ou non. Il va recuperer le tableau des cases possibles a jouer, il va ensuite le parcourir et mettre Possible a 'Y' (yes), si au moins une des cases est possible. Sinon il met Possible a 'N' (non).
possible_to_play(Board, Player, Possible) :- list_possible_correct_moves(Board, Player, CorrectMoves),((possible_to_play_in_row(CorrectMoves), Possible = 'Y') ; Possible = 'N'), !.

possible_to_play_in_row([]) :- fail.
possible_to_play_in_row([T|Q]) :- possible_to_play_in_box(T) ; possible_to_play_in_row(Q).

possible_to_play_in_box([]) :- fail.
possible_to_play_in_box([T|Q]) :- T = 'Y' ; possible_to_play_in_box(Q).

%predicat qui compte le nombre de pions de chaque joueur, il va recursivement parcourir tout le tableau (parcours chaque ligne et pour chaque ligne chaque element), et si un element est non variable, soit Joueur1 est incremente, soit Joueur2 est incremente.
count_in_row([], Joueur1, Joueur2) :- Joueur1 is 0, Joueur2 is 0.
count_in_row([T|Q], Joueur1, Joueur2) :- count_in_box(T, NbInRowJoueur1, NbInRowJoueur2), count_in_row(Q, NbNextJoueur1, NbNextJoueur2), Joueur1 is NbInRowJoueur1 + NbNextJoueur1, Joueur2 is NbInRowJoueur2 + NbNextJoueur2.

count_in_box([], Joueur1, Joueur2) :- Joueur1 is 0, Joueur2 is 0.
count_in_box([T|Q], Joueur1, Joueur2) :- ((var(T), NbHereJoueur1 is 0, NbHereJoueur2 is 0) ; (T = 'x', NbHereJoueur1 is 1, NbHereJoueur2 is 0) ; (T = 'o', NbHereJoueur1 is 0, NbHereJoueur2 is 1)), count_in_box(Q, NbNextJoueur1, NbNextJoueur2), Joueur1 is NbHereJoueur1 + NbNextJoueur1, Joueur2 is NbHereJoueur2 + NbNextJoueur2.

liste_coordinates_correct_moves(CorrectMoves,R,C):-findall([X,Y],get_element(CorrectMoves, X, Y, 'Y'),ListesCoord),random_move(ListesCoord,R,C).
random_move(ListesCoord,R,C):-random_member(Coord,ListesCoord),nth0(0,Coord,R),nth0(1,Coord,C).
