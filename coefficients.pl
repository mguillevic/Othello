coeffCase(X,Y,-150):-
    X=0,Y=1; X=0,Y=6; X=1,Y=0; X=1,Y=7; 
    X=6,Y=0; X=6,Y=7; X=7,Y=1; X=7,Y=6.

coeffCase(X,Y,500):-
    X=0,Y=0; X=7,Y=0; X=0,Y=7; X=7,Y=7.

coeffCase(X,Y,30):-
    X=2,Y=0; X=5,Y=0; X=2,Y=7; X=5,Y=7;
	X=0,Y=2; X=0,Y=5; X=7,Y=2; X=7,Y=5.

coeffCase(X,Y,10):-
	X=3,Y=0; X=4,Y=0; X=3,Y=7; X=4,Y=7;
	X=0,Y=3; X=0,Y=4; X=7,Y=3; X=7,Y=4.

coeffCase(X,Y,16):-
    X=3,Y=3; X=4,Y=3; X=3,Y=4; X=4,Y=4.

coeffCase(X,Y,1):-
    X=2,Y=2; X=2,Y=5; X=5,Y=2; X=5,Y=5.

coeffCase(X,Y,-250):-
    X=1,Y=1; X=1,Y=6; X=6,Y=1; X=6,Y=6.

coeffCase(X,Y,2):-
    X=2,Y=3; X=2,Y=4; X=3;Y=2, X=3,Y=5; X=4,Y=2; X=4,Y=5; X=5,Y=3; X=5,Y=4.

coeffCase(X,Y,0):-
    (X=1;X=6),(Y=2;Y=3;Y=4;Y=5); (Y=1;Y=6),(X=2;X=3;X=4;X=5).