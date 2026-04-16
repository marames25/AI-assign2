% STATE:
% state(R, C, RemainingSurvivors, Collected)

% HEURISTIC:
% H = -(Collected * 100) + distance_to_nearest_survivor


grid(1, [[r, e, d, e, e],
         [e, e, f, e, s],
         [d, e, e, e, d],
         [e, s, e, f, s]]).

grid(2, [[r, e, s],
         [d, f, e],
         [e, s, e]]).

grid(3,[
  [r, d, d, s, e],
  [e, s, s, e, d],
  [e, f, f, e, d],
  [e, e, d, e, e],
  [f, e, e, e, e]
]).
get_survivors(Grid, Survivors) :-
    findall((R,C),
        (nth1(R, Grid, Row),
         nth1(C, Row, s)),
        Survivors).


find_robot(Grid, R, C) :-
    nth1(R, Grid, Row),
    nth1(C, Row, r).


valid(R, C, Grid) :-
    length(Grid, MaxR),
    nth1(1, Grid, FirstRow),
    length(FirstRow, MaxC),
    R >= 1, R =< MaxR,
    C >= 1, C =< MaxC,
    nth1(R, Grid, Row),
    nth1(C, Row, V),
    V \= d,
    V \= f.


move(state(R,C,Surv,Coll), state(NR,NC,NSurv,NColl), Grid) :-
    (NR is R-1, NC is C;
     NR is R+1, NC is C;
     NR is R, NC is C-1;
     NR is R, NC is C+1),

    valid(NR, NC, Grid),

    nth1(NR, Grid, Row),
    nth1(NC, Row, Cell),

    ( Cell == s, member((NR,NC), Surv) ->
        delete_one(Surv, (NR,NC), NSurv),
        NColl is Coll + 1
    ;
        NSurv = Surv,
        NColl is Coll
    ).


delete_one([H|T], H, T) :- !.
delete_one([H|T], X, [H|NT]) :- delete_one(T, X, NT).

manual_abs(A, B, D) :-
    (A >= B -> D is A - B ; D is B - A).

heuristic(R, C, Remaining, Collected, H) :-
    ( Remaining = [] ->
        H is -(Collected * 100)
    ;
        findall(D,
            (member((SR,SC), Remaining),
             manual_abs(R, SR, DR),
             manual_abs(C, SC, DC),
             D is DR + DC),
            Ds),
        msort(Ds, [Min|_]),
        H is -(Collected * 100) + Min
    ).


solve(N) :-
    grid(N, Grid),
    get_survivors(Grid, Survivors),
    find_robot(Grid, SR, SC),
    heuristic(SR, SC, Survivors, 0, H),
    search([[H, state(SR,SC,Survivors,0), [(SR,SC)]]],
           [],
           Grid,
           null,
           0),
    !.


search([], _, _, null, _) :-
    write('No path found'), nl.

search([], _, _, BestPath, Max) :-
    BestPath \= null,
    print_result(BestPath, Max).

search([[_, State, Path] | Rest], Closed, Grid, BestPath, Max) :-

    State = state(R,C,Rem,Coll),

    ( Coll > Max ->
        NewBestPath = Path,
        NewMax = Coll
    ;
        NewBestPath = BestPath,
        NewMax = Max
    ),

    findall([H2, NextState, NewPath],
        (
            move(State, NextState, Grid),
            NextState = state(NR,NC,NewRem,NColl),

            \+ member((NR,NC), Path),
            \+ member((NR,NC,NewRem), Closed),

            append(Path, [(NR,NC)], NewPath),

            heuristic(NR, NC, NewRem, NColl, H2)
        ),
        Children),

    append(Rest, Children, Open1),
    msort(Open1, Sorted),

    search(Sorted, [(R,C,Rem)|Closed], Grid, NewBestPath, NewMax).


print_path([]).
print_path([(R,C)]) :-
    format("(~w,~w)", [R,C]).
print_path([(R,C)|Rest]) :-
    format("(~w,~w) -> ", [R,C]),
    print_path(Rest).


print_result(Path, Coll) :-
    length(Path, Len),
    Steps is Len - 1,
    write('Path found: '),
    print_path(Path), nl,
    write('Survivors rescued: '), write(Coll), nl,
    write('Number of steps: '), write(Steps), nl,
    !.
