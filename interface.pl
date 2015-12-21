:- initialization(start).

start :-
			nl,write('Que voulez-choisir?'),nl,
			write('    '),write('1- Homme contre Homme'),nl,
			write('    '),write('2- Homme contre Machine'),nl,
			write('    '),write('3- Machine contre Machine'),nl,
			read(Choix),
			choice(Choix).
			
			
choice(1) :- !,[jeu_H_Vs_H],begin.
choice(2) :- !,[jeu_H_Vs_O],begin.
choice(3) :- !,[jeu_O_Vs_O],begin.
choice(_) :- nl,write('Votre choix doit etre compris entre 1 et 3!!'),start.
