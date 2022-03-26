/**
 * @project    FLP project - Hamiltonian cycle
 * @brief      Main file, reads and parses input, computes Hamiltonian cycle.
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


%%%%%%%%%%%%%%%%%%%%%%%%%%% output %%%%%%%%%%%%%%%%%%%%$$$$$$$$%%%%%%%%%%%%%%%%

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
   write("-"),
   write(B),
   (T = [] ->
      nl
      ;
      write(" "),
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
   split_string(Str, ' ', ' ', [A,B]),
   assertz(edge(A,B)).

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
get_cycles([], []).
get_cycles([HPoint|TPoints], Out) :-
   find_next(HPoint, TPoints, PathPoints),
   path(PathPoints, TPoints, [HPoint], Paths),
   remove_reversed_dup(Paths, Out).

% results are there twice, but reversed:
% A -> B -> C -> A and A -> C -> B -> A (same cycle, different orientation)
remove_reversed_dup([], []).
remove_reversed_dup([H|T], Out) :-
   reverse(H, X),
   member(X, T),
   remove_reversed_dup(T, Out).
remove_reversed_dup([H|T], [H|Out]) :-
   remove_reversed_dup(T, Out).


% end of search -> check if there is path between last and first
% point (only path not checked, yet)
path(_ , [], [HV|TVisited], [Out]) :-
   last(TVisited, LV),
   ispath(LV, HV, _),
   get_edges_from_path(LV, [HV|TVisited], Out).
% there is no path(edge) between first and last point
path(_, [], _, []).

% find path through all nodes using depth first search
path([HPP|TPP], NV, Visited, Out) :-
   select(HPP, NV, NVNew),
   find_next(HPP, NVNew, PathPointsNew),
   path(PathPointsNew, NVNew, [HPP|Visited], ONew), % search this path (DFS)
   path(TPP, NV, Visited, ONext), % then go to next path (node)
   append(ONew, ONext, Out).

% no other possible edges
path([], _, _, []).

% find all posible points which has edge with X
find_next(X, [H|T], [H|TP]) :-
   ispath(X, H, _),
   find_next(X, T, TP).
find_next(X, [_|T], P) :-
   find_next(X, T, P).
find_next(_, [], []).

get_edges_from_path(_, [], []).
get_edges_from_path(X, [H|T], [E|NOut]) :-
   ispath(X, H, E),
   get_edges_from_path(H, T, NOut).


ispath(X, Y, edge(X, Y)) :-
   edge(X, Y).
ispath(Y, X, edge(X, Y)) :-
   edge(X, Y).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main :-
   read_input(Lines),
   parse_points_edges(Lines, Points),
   get_cycles(Points, Out),
   print_cycles(Out),
   halt.

%% end of file