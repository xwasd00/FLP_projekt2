/**
 * @brief      This file implements main.
 *
 * @author     Michal Sova (xsovam00@stud.fit.vutbr.cz)
 * @date       2022
 *
 */


%%%%%%%%%%%%%%%%%%%%%%%%%%% input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/**
 * @brief      Reads an input and parses it to parameter Lines.
 *
 * @return     list of output lines in Lines
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
 * @brief      Gets the line from stdin, reads stdin until EOF or newline.
 *
 * @return     line from standard input in Line
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
 * @brief      Prints Ham. circles from list.
 */
print_circles([]).
print_circles([H|T]) :-
   print_circle(H),
   print_circles(T).

/**
 * @brief      Prints Ham. circle from list of edges.
 */
print_circle([edge(A,B)|T]) :-
   write(A),
   write("-"),
   write(B),
   (T = [] ->
      nl
      ;
      write(" "),
      print_circle(T)
   ).


%%%%%%%%%%%%%%%% points and edges construction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/**
 * @brief      Parse points and edges from list of lines of input, add edges to
 *             knowledge base.
 *
 * @return     The points.
 */
parse_points_edges([], []).
parse_points_edges([H|T], Points) :-
   get_edge(H, PFromEdge),
   parse_points_edges(T, P),
   append_unique(PFromEdge, P, Points).

get_edge(Str, [A,B]) :-
   split_string(Str, ' ', ' ', [A,B]),
   assertz(edge(A,B)).

append_unique([], L, L).
append_unique([X|XS], L, O) :-
   member(X, L),
   append_unique(XS, L, O).
append_unique([X|XS], L, [X|O]) :- append_unique(XS, L, O).


%%%%%%%%%%%%%%%%%%%%%%% Hamiltonian path %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_circles([], []).
get_circles(Points, Out):-
   Out = []. %TODO



%%%%%%%%%%%%%%%%%%%%%%%%%%%%% main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main :-
   read_input(Lines),
   parse_points_edges(Lines, Points),
   get_circles(Points, Out),
   print_circles(Out),
   halt.

%% end of file