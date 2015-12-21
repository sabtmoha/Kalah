%-----------------------------------------------------------------------------------------------------------------------------------------------
%                                                    Divers utilitaires de jeu                                                                            
% 
%-----------------------------------------------------------------------------------------------------------------------------------------------
nth_number(N,[T|Q],K):- N>1, !, New_N is N-1, nth_number(New_N,Q,K).
nth_number(1,[T|Q],T).

n_substitute(1,[T|Q],X,[X|Q]) :- !.
n_substitute(N,[T|Q1],X,[T|Q2]) :- N>1, !, New_N is N-1, n_substitute(New_N,Q1,X,Q2).

swap(plateau(Hs,K,Ys,L),plateau(Ys,L,Hs,K)).

max(A,B,A):- A > B,!.
max(A,B,B):- A =< B.

inverser(L,IL):-renverser(L,[],IL).

renverser([],L,L).
renverser([T|Q],L,R):- renverser(Q,[T|L],R).

member(T,[T|_]) :- !.
member(T,[X|Q]) :- member(T,Q).
%-----------------------------------------------------------------------------------------------------------------------------------------------
%                                                    Cadre de jeu                                                                            
% 
%-----------------------------------------------------------------------------------------------------------------------------------------------
begin :- 
			nl,write('   Vous avez choisi de jouer contre moi!!'),
			initialise(Position, Player),     %Player sera unifie toujours avec la constante player  
			play(Position, Player, Result).	  %% Player qui joue toujours en premier

								
play(Position, Player, Result):-
									game_over(Position, Player, Result), !,  % Position joue le même rôle que celui de Board
									announce(Result),
									%rinitialisation(),play().
play(Position, Player, Result):-
									repeat,
									display_game(Position),				%%affichage avant de jouer
									choose_move(Position, Player, Move),
									Exmove(Move,Position,New_Board,Again),
									Again = 0,!,
									display_game(New_Board),     %%affichage apres avoir joue
									next_player(Player,New_Player),!,   %%determine le joueur suivant 
									swap(New_Board,New_Position),       %%inverser le plateau
									play(New_Position,New_Player,Result).  %%rejouer avec le nouveau joueur et nouveau plateau
%-----------------------------------------------------------------------------------------------------------------------------------------------
%                                                    Initialisation                                                                            
% Ce predicat initialise jeu. il prend comme un parametres  plateau il unifie avec plateau initial ou chaque puit contient 7 pierres et
% les magasins sont vides. Ce predicat renvoie toujours vrai.
%-----------------------------------------------------------------------------------------------------------------------------------------------
initialise (plateau([N,N,N,N,N,N,N],0,[N,N,N,N,N,N,N],0),player):- piece(N).

piece(7).
%
%
%%-----------------------------------------------------------------------------------------------------------------------------------------------
%                                                     Affichage                                                                            
%Ce predicat affiche le plateau. Il renvoie toujours vrai 
%-----------------------------------------------------------------------------------------------------------------------------------------------
display_game(plateau(Puits1, Magasin1,Puits2, Magasin2 )):-
																nl,
																inverser(Puits2, Ipuits2),write('   '),write_stones(Ipuits2),
																nl,
																write_store(Magasin1,Magasin2),
																nl,
																write('   '),write_stones(Puits1).

write_stones([T|Q]):-T<10,write(T),write('  '),write_stones(Q),!.
write_stones([T|Q]):-T>=10,write(T),write(' '),write_stones(Q).
write_stones([]).

write_store(Magasin1, Magasin2):- write(Magasin2),write('                      '),write(Magasin1).


%%-----------------------------------------------------------------------------------------------------------------------------------------------
%                                                     next_player(Curr_player,Next_player)                                                                            
%Ce predicat determine le joueur suivant. Il prend comme des parametres le joueur qui il vient de joueur et il unifie le joueur suivant avec 
%Next_player. Il renvoie toujours vrai 
%-----------------------------------------------------------------------------------------------------------------------------------------------
next_player(computer,player).
next_player(player,computer).

%%-----------------------------------------------------------------------------------------------------------------------------------------------
%                                                     Test de fin de jeu                                                                            
%
%-----------------------------------------------------------------------------------------------------------------------------------------------
game_over(plateau([],M,[],M),Player,draw) :-  piece(N),M = 7*N ,!.			%%Test si il ny a plus des pierres pour jouer
game_over(plateau(_,K,_,L),Player,Player) :- piece(N), K > 7*N,!.   %%Test si Player a deja plus que la moitie des pierres
game_over(plateau(_,K,_,L),Player,Opponent) :- piece(N), L > 7*N, next_player(Player,Opponent).

announce(player) :- write('You won, Congratulations!'),nl.
announce(computer) :- write('I won'),nl.
announce(draw) :- write('The game is a draw'),nl.

%%-----------------------------------------------------------------------------------------------------------------------------------------------
%                                                     Fonction d'evaluation                                                                           
%
%-----------------------------------------------------------------------------------------------------------------------------------------------
 value(plateau(H,K,Y,L),Value) :- Value is K-L. 
 
 
 %%-----------------------------------------------------------------------------------------------------------------------------------------------
%                                                     Executer un mouvement                                                                           
%A REVOIR!!!!!
%-----------------------------------------------------------------------------------------------------------------------------------------------
 Exmove([],Board,Board,0):- !.
 Exmove([N|Ns],Board,FinalBoard,Again) :- 
									nth_member(N,Board,Stones),
									faire_vider(N,Board,Nouveau_Board),
									Hole_Suivant is N+1,
									distribute_stones(Stones,Hole_Suivant,Nouveau_Board,New_Board,Again1),
									move(Ns,New_Board,FinalBoard,Again2),
									max(Again1,Again2,Again).
 
 faire_vider (N,plateau(Puits1,Magasin1,Puits2,Magasin2)
			,plateau(New_Puits1,Magasin1,Puits2,Magasin2)) :-n_substitute(N,Puits1,0,Puits2).

 
 
%%-----------------------------------------------------------------------------------------------------------------------------------------------
%                                                     Distribution                                                                           
%
%-----------------------------------------------------------------------------------------------------------------------------------------------
check_capture(Hole,Stones,Puits1,New_Puits1,Puits2,New_Puits2,Pieces) :-
																			FinishingHole is Hole + Stones - 1,
																			nth_member(FinishingHole,Puits1,Pieces_into_FinishingHole),
																			Pieces_into_FinishingHole = 1,
																			OppositeHole is 8 - FinishingHole,
																			nth_member(OppositeHole,Puits2,Pieces_Capture),
																			n_substitute(FinishingHole,Puits1,0,New_Puits1),
																			n_substitute(OppositeHole,Puits2,0,New_Puits2),
																			Pieces is Pieces_Capture + 1.
check_capture(_,_,Puits1,Puits1,Puits2,Puits2,0) :- !.


update_magasin(Pieces,Hole,Stones,Magasin1,New_Magasin1) :- Stones < 8-Hole+1, !, New_Magasin1 is Magasin + Pieces. 
update_magasin(Pieces,Hole,Stones,Magasin1,New_Magasin1) :- Stones = 8-Hole+1, New_Magasin1 is Magasin + Pieces+1.


check_if_finished1(8,_,0,1) :- !. %Dans le magasin
check_if_finished1(FinishingHole,Puits1,Pieces_into_FinishingHole,0) :- nth_member(FinishingHole,Puits1,Pieces_into_FinishingHole).
											
											

distribute_stones(0,_,Board,Board,0) :- !.
distribute_stones(Stones,Hole,Board,FinalBoard,Again) :-
														distribute_my_holes(Stones,Hole,Board,Board1,Stones1,Again1),
														distribute_your_holes(Stones1,1,Board1,New_Board,New_Stones),
														distribute_stones(New_Stones,1,New_Board,FinalBoard,Again2),
														max(Again1,Again2,Again).

	
	
distribute_my_holes(0,_,Board,Board,0,0) :- !.													
distribute_my_holes(Stones,Hole,plateau(Puits1,Magasin1,Puits2,Magasin2),
			plateau(New_Puits1,New_Magasin1,Puits2,Magasin2),New_Stones,0) :-
																				Stones > 8-Hole-1,!,
																				distribute(Hole,Stones,Puits1,New_Puits1),
																				New_Magasin1 is Magasin1+1,
																				New_Stones is Stones + Hole - 8 - 1.																						
distribute_my_holes(Stones,Hole,plateau(Puits1,Magasin1,Puits2,Magasin2),
										New_Board,New_Stones,Again) :-
																		distribute(Hole,Stones,Puits1,Nouveau_Puits1),
																		check_capture(Hole,Stones,Nouveau_Puits1,New_Puits1,Puits2,New_Puits2,Pieces),
																		update_magasin(Pieces,Hole,Stones,Magasin1,New_Magasin1),
																		FinishingHole is Hole + Stones - 1,
																		check_if_finished1(FinishingHole,New_Puits1,Stones_in_FHole,Again1),
																		n_substitute(FinishingHole, New_Puits1,0, Newest_Puits1),
																		FinishingHole_suivant is FinishingHole +1,
																		distribute_my_holes(Stones_in_FHole,FinishingHole_suivant,
																		   plateau(Newest_Puits1,New_Magasin1,New_Puits2,Magasin2), New_Board,New_Stones,Again2),            
																		max(Again1,Again2,Again).
	
	
distribute_your_holes(0,_,Board,Board) :- !.
distribute_your_holes(Stones,Hole,plateau(Puits1,Magasin1,Puits2,Magasin2),
			plateau(Puits1,Magasin1,New_Puits2,Magasin2),New_Stones) :-
																		Stones >= 8-Hole,!,
																		distribute(Hole,Stones,Puits2,New_Puits2),
																		New_Stones is Stones+Hole-8+1.
distribute_your_holes(Stones,Hole,plateau(Puits1,Magasin1,Puits2,Magasin2),
											New_Board,New_Stones) :-
																		distribute(Hole,Stones,Puits2,New_Puits2),
																		FinishingHole is Hole + Stones -1,
																		nth_member(FinishingHole,New_Puits2,Stones_in_FHole),
																		Stones_in_FHole > 1,!,
																		n_substitute(FinishingHole, New_Puits2,0, Newest_Puits2),
																		FinishingHole_suivant is FinishingHole +1,
																		distribute_your_holes(FinishingHole_suivant,Stones_in_FHole
																		   ,plateau(Puits1,Magasin1,Newest_Puits2,Magasin2), New_Board,New_Stones).
distribute_your_holes(Stones,Hole,plateau(Puits1,Magasin1,Puits2,Magasin2)
				,plateau(Puits1,Magasin1,New_Puits2,Magasin2),0) :-  
																		distribute(Hole,Stones,Puits2,New_Puits2).
																		   
																		   
%n_substitute(FinishingHole, New_Puits1,0, Newest_Puits1),
%FinishingHole_suivant is FinishingHole +1,

																		   
distribute(_,0,Puits,Puits) :- !.     % si 0 pierre distribuees
distribute(8,_,Puits,Puits) :- !.     % Si on le magasin est le prochain
distribute(Hole, Stones, Puits,New_Puits) :- 
												member(Hole,[1,2,3,4,5,6,7]),!,  % si bien le prochain est un puits non un magasin
												Stones > 0,                   % on vérifie encore
												nth_number(Hole,Puits,Stones_in_Hole),    
												New_Stones_in_Hole is Stones_in_Hole + 1,
												n_substitute(Hole,Puits,New_Stones_in_Hole,Nouveau_Puits),   % Augmenter le nombre de pierres dans le puits visites
												Hole_suivant is Hole + 1,         % Avancer de un pas
												New_Stones is Stones - 1,     % Diminuer le nombre de pierres
												distribute(Hole_suivant, New_Stones, Nouveau_Puits,New_Puits).  % On relance la procedure

										
																		
