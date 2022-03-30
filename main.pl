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
 * print_cycles(+List, +Size).
 *
 * @brief      Prints Ham. cycles from list.
 *
 * @param      List      list of Ham. cycles
 * @param      Size      size of Ham. cycles, anything with wrong size will be ignored
 */
print_cycles([], _).
print_cycles([H|T], Size) :-
   (length(H, Size) ->
      print_cycle(H),
      print_cycles(T, Size)
      ;
      print_cycles(T, Size)
   ).

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
   perm_half(TPoints, OutC),
   path(HPoint, OutC, Out).

/**
 * perm_half(+List1, -List2).
 * 
 * @brief      Get half the permutations of points needed for solving the path
 *             because path([1,2,3]) == path([3,2,1])
 *
 * @param      List1     The list of points
 * @param      List2     The list of permutations of points
 */
perm_half([], []).
perm_half([X, Y], [[X, Y]]).
perm_half([H|T], Out) :-
   perm_half(T, OutPart),
   combine(H, OutPart, Out).

/**
 * combine(+Element, +List1, -List2).
 * 
 * @brief      combine element X with rest of the list -> inserts element X to
 *             all possible positions, X & [A, B] -> [[X,A,B], [A,X,B], [A,B,X]]
 *
 * @param      Element   Element to be inserted
 * @param      List1     List of points
 * @param      List2     List of resulting lists
 */
combine(_, [], []).
combine(X, [H|T], Out) :-
   setof(O, select(X, O, H), Combinations), 
   combine(X, T, OutRest),
   append(Combinations, OutRest, Out).

/**
 * path(+Start, +Perms, -Paths).
 * 
 * @brief      Search paths from Start through all points of all permutations ending back at Start
 *
 * @param      Start     Starting and ending point
 * @param      Perms     List of permutations of all other points (except Start)
 * @param      Paths     List of relevant paths given the permutations (could be Ham. cycle => depends on size of the path)
 */
path(_, [], []).
path(Start, [HPerms|TPerms], [Path|OtherPaths]) :-
   path(Start, TPerms, OtherPaths),
   append(HPerms, [Start], NewPerms),
   get_path(Start, NewPerms, Path).

/**
 * get_path(+Point, +Points, -Edges).
 * 
 * @brief      Get list of relevant edges from points
 *
 * @param      Point     Starting point
 * @param      Points    List of other points in path
 * @param      Edges     List of edges created by points
 */
get_path(_, [], []).
get_path(Point, [H|T], Edges) :-
   (ispath(Point, H, Edge) ->
      get_path(H, T, NEdges),
      Edges = [Edge|NEdges]
      ;
      Edges = []
   ).

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main :-
   read_input(Lines),
   parse_points_edges(Lines, Points),
   get_cycles(Points, Out),
   length(Points, Size),
   print_cycles(Out, Size),
   halt.

%% end of file