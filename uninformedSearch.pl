% GRID DEFINITION
grid([[r, e, e], 
[d, f, e], 
[e, e, s]]).

grid([[r, e, d, e, e],
      [e, e, f, e, s],
      [d, e, e, e, e],
      [e, s, e, f, e]]).



% value in position [x][y]
cell(Grid, X, Y, Value) :-
    nth0(X, Grid, Row),
    nth0(Y, Row, Value).



% finding the start position
start(Grid, X, Y) :-
    nth0(X, Grid, Row), % generates all rows
    nth0(Y, Row, r).    % takes Row and r then returns the value of Y

% goal check ([x][y] == s)
goal(Grid, X, Y) :-
    cell(Grid, X, Y, s).


% checks if the cell is valid
valid(Grid, X, Y) :-
    X >= 0, Y >= 0,

    length(Grid, N),
    X < N,

    nth0(X, Grid, Row),
    length(Row, M),
    Y < M,
    % impassable cells 
    cell(Grid, X, Y, Value),
    Value \= d,
    Value \= f.

% generator that generates all the next moves
move(X, Y, NX, NY) :-
    (NX is X+1, NY is Y;
     NX is X-1, NY is Y;
     NX is X, NY is Y+1;
     NX is X, NY is Y-1).


% takes the grid and the cell (x,y) to generate its neighbors
neighbors(Grid, (X,Y,Path), Visited, Neighbors) :-
    % appends the valid results of the predicate to the Neighbors in form of (NX,NY,NewPath) 
    findall((NX,NY,NewPath),

        (
            % generate possible moves
            move(X,Y,NX,NY),

            % continue if valid
            valid(Grid,NX,NY),

            % continue if not visited
            \+ member((NX,NY), Visited),

            % build new path
            append(Path, [(NX,NY)], NewPath)
            
            % now append the valid result into neighbors
        ),

        Neighbors
    ).




% Queue = list of states
% State = (X,Y,Path)
% [(Head)|Rest] = queue front + rest

% Failure case
bfs(_, [], _, _) :- fail.

% check first if it is the goal, if so this predicate is called first and the algorithm is terminated
% if no continue to the full algorithm
bfs(Grid, [(X,Y,Path)|_], _, Path) :-
    goal(Grid, X, Y).

% Main BFS step
bfs(Grid, [(X,Y,Path)|RestQueue], Visited, Result) :-

    % generate all valid neighbors
    neighbors(Grid, (X,Y,Path), Visited, Neigh),

    % Extract only positions from neighbors and put them in the list (NewVisitedPart)
    findall((NX,NY),
        member((NX,NY,_), Neigh), % generates all the elements in Neigh
        NewVisitedPart
    ),

    append(Visited, NewVisitedPart, NewVisited),

    % Queue update (push back)
    append(RestQueue, Neigh, NewQueue),

    % Recursive call
    bfs(Grid, NewQueue, NewVisited, Result).

% entry point
solve(Path, Steps, Battery) :-
    grid(Grid),

    % Find start position (r)
    start(Grid, X, Y),

    % start bfs with the queue having the start position (r) and the path to it,
    % and a list of visited cells (only r at the begining) 
    bfs(Grid, [(X,Y,[(X,Y)])], [(X,Y)], Path),

    length(Path, L),
    Steps is L - 1,
    Battery is 100 - Steps * 10,

    ( Battery >= 0 ->
        true
    ;
        write('Battery ran out!'), nl,
        fail
    ).



run :-
    ( solve(Path, Steps, Battery) ->
        write('Path: '), write(Path), nl,
        write('Steps: '), write(Steps), nl,
        write('Battery: '), write(Battery), nl
    ;
        write('No path to any survivor found.'), nl
    ).