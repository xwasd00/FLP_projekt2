/**
 * @project    FLP project - Hamiltonian cycle
 * @brief      Main file, reads and parses input, computes Hamiltonian cycley,
 *             prints Ham. cycles.
 *
 * @author     Michal Sova (xsovam00@stud.fit.vutbr.cz)
 * @date       2022
 * @file main.pl
 */


%%%%%%%%%%%%%%%%%%%%%%%%%%% input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/**
 * read_input(-Lines).
 * 
 * @brief      Reads an input and parses it to parameter Lines.
 *
 * @param      Lines     list of output lines
 */
read_input(Lines) :- 
   get_line(L),
   (L = '' ->
      Lines = []
      ;
      Lines = [L|NLines],
      read_input(NLines)
   ).

/**
 * get_line(-Line).
 * 
 * @brief      Gets the line from stdin, reads stdin until EOF or newline.
 *
 * @param      Line      line from standard input
 */
get_line(Line) :-
   get_char(C),
   (C = end_of_file -> 
      Line = ''
      ;
      (C = '\n' -> 
         Line = ''
         ;
         get_line(NLine),
         string_concat(C, NLine, Line)
      )
   ).


%%%%%%%%%%%%%%%%%%%%%%%%%%% output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/**
 * print_cycles(+List).
 *
 * @brief      Prints Ham. cycles from list.
 *
 * @param      List      list of Ham. cycles
 */
print_cycles([]).
print_cycles([H|T]) :-
   print_cycle(H),
   print_cycles(T).

/**
 * print_cycle(+List).
 * 
 * @brief      Prints Ham. cycle from list of edges.
 * 
 * @param      List      list of edges
 */
print_cycle([edge(A,B)|T]) :-
   write(A),
   write('-'),
   write(B),
   (T = [] ->
      nl
      ;
      write(' '),
      print_cycle(T)
   ).


%%%%%%%%%%%%%%%% points and edges construction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/**
 * parse_points_edges(+List, -Points).
 *
 * @brief      Parse points and edges from list of lines of input, add edges to
 *             knowledge base.
 * 
 * @param      List      list of lines with edges
 * @param      Points    list of points
 */
parse_points_edges([], []).
parse_points_edges([H|T], Points) :-
   get_edge(H, PFromEdge),
   parse_points_edges(T, P),
   append_unique(PFromEdge, P, Points).

/**
 * get_edge(+String, -Pair).
 * 
 * @brief      Gets the edge and points.
 *
 * @param      Str   The string in form "A B"
 * @param      Pair  List of two values - points
 */
get_edge(Str, [A,B]) :-
   atomic_list_concat([A,B], ' ', Str),
   assertz(edge(A,B)).

%TODO: split_string - neni na merlinu

/**
 * append_unique(+List1, +List2, -List3).
 * 
 * @brief      Merges List1 and List2, result list in List3.
 *
 * @param      List1     first list to join
 * @param      List2     second list to join
 * @param      List3     result list
 * 
 * Example:
 * 
 * ?- append_unique([1, 2], [2, 3], X).
 * X = [1, 2, 3]
 */
append_unique([], L, L).
append_unique([X|XS], L, O) :-
   member(X, L),
   append_unique(XS, L, O).
append_unique([X|XS], L, [X|O]) :- append_unique(XS, L, O).


%%%%%%%%%%%%%%%%%%%%%%% Hamiltonian cycle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/**
 * get_cycles(+Points, -List).
 * 
 * @brief      Find all hamiltonian cycles and remove duplicates.
 *
 * @param      Points    The list of all points in graph
 * @param      List      The resulting list of hamiltonian cycles
 */
get_cycles([], []).
get_cycles([HPoint|TPoints], Out) :-
   find_next(HPoint, TPoints, PathPoints),
   path(PathPoints, TPoints, [HPoint], Paths),
   remove_reversed_dup(Paths, Out).

/**
 * path(+PathPoints, +Unvisited, +Visited, -Out).
 *
 * @brief      searching all paths of hamiltonian cycle, using backtracking
 *             algorithm
 *
 * @param      PathPoints  list of points which could be visited (has edge to first
 *                         point in Visited list), 'next state' of backtracking
 *                         algorithm
 * @param      Unvisited   list of points yet to be visited (for find_next ->
 *                         remaining points that are relevant for finding
 *                         hamiltonian cycle)
 * @param      Visited     list of visited points, first point of this list is
 *                         'current state' in backtracking algorithm
 * @param      Out         list of found hamiltonian cycles
 */
% end of search and there is path between last and first point
path(_ , [], [HV|TVisited], [Out]) :-
   last(TVisited, LV),
   ispath(LV, HV, _),
   get_edges_from_points(LV, [HV|TVisited], Out).

% end of path and there is NO path (edge) between first and last point
path(_, [], _, []).

% find path through all nodes using backtracking
path([HPP|TPP], Unvisited, Visited, Out) :-
   select(HPP, Unvisited, NewU), % remove state (HPP) from list of unvisited points
   find_next(HPP, NewU, PathPointsNew), % expand new possible states from state HPP
   path(PathPointsNew, NewU, [HPP|Visited], ONew), % search this state HPP
   path(TPP, Unvisited, Visited, ONext), % then 'backtrack' to next states
   append(ONew, ONext, Out). 

% no other possible edges
path([], _, _, []).

/**
 * get_edges_from_points(+Point, +Points, -Edges).
 * 
 * @brief      Gets the edges from points.
 *
 * @param      Point     starting point
 * @param      Points    list of other points in path
 * @param      Edges     list of edges crated by points
 */
get_edges_from_points(_, [], []).
get_edges_from_points(Point, [HPoints|TPoints], [Edge|NEdges]) :-
   ispath(Point, HPoints, Edge),
   get_edges_from_points(HPoints, TPoints, NEdges).

/**
 * find_next(+Point, +Points, -OutP).
 * 
 * @brief      find all possible points from Points which has edge with Point
 *
 * @param      Point     starting point
 * @param      Points    list of other points to find edges to
 * @param      OutP      list of points that has edge to Point
 */
find_next(_, [], []).
find_next(Point, [HPoints|TPoints], [HPoints|OutP]) :-
   ispath(Point, HPoints, _),
   find_next(Point, TPoints, OutP).

find_next(Point, [_|TPoints], OutP) :-
   find_next(Point, TPoints, OutP).

/**
 * ispath(+X, +Y, -E).
 * 
 * @brief      checks if there is edge between two points
 *
 * @param      X         first point
 * @param      Y         second point
 * @param      E         resulting edge
 */
ispath(X, Y, edge(X, Y)) :- 
   edge(X, Y).
ispath(Y, X, edge(X, Y)) :- 
   edge(X, Y).

/**
 * remove_reversed_dup(+List1, -List2).
 *
 * @brief      Removes a reversed duplicate. -- results are there twice, but
 *             reversed: A -> B -> C -> A and A -> C -> B -> A (same cycle,
 *             different orientation)
 *
 * @param      List1     List with hamiltonian cycles
 * @param      List2     List wihout duplicates
 */
remove_reversed_dup([], []).
remove_reversed_dup([H|T], Out) :-
   reverse(H, X),
   member(X, T),
   remove_reversed_dup(T, Out).
remove_reversed_dup([H|T], [H|Out]) :-
   remove_reversed_dup(T, Out).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main :-
   read_input(Lines),
   parse_points_edges(Lines, Points),
   get_cycles(Points, Out),
   print_cycles(Out),
   halt.

%% end of file