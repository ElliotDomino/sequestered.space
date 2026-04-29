:- use_module(library(lists)).

count(_, [], 0).

count(X, [X|T], N) :-
  count(X, T, N1),
  N is N1 + 1.

count(X, [Y|T], N) :-
  X \= Y,
  count(X, T, N).

% Check to see that each color exists in 9 spots

% Flatten cube faces into one 54-color list

cube_colors(
    cube(up(U), left(L), front(F), right(R), back(B), down(D)),
    Colors
) :-
    append([U, L, F, R, B, D], Colors).

valid_face_length([_,_,_,_,_,_,_,_,_]).

valid_face_lengths(
    cube(up(U), left(L), front(F), right(R), back(B), down(D))
) :-
    valid_face_length(U),
    valid_face_length(L),
    valid_face_length(F),
    valid_face_length(R),
    valid_face_length(B),
    valid_face_length(D).

valid_color_counts(Cube) :-
    cube_colors(Cube, Colors),
    count(white, Colors, 9),
    count(yellow, Colors, 9),
    count(red, Colors, 9),
    count(orange, Colors, 9),
    count(blue, Colors, 9),
    count(green, Colors, 9).

% ---------- validate centers ----------

valid_centers(
    cube(
        up([_,_,_,_,white,_,_,_,_]),
        left([_,_,_,_,orange,_,_,_,_]),
        front([_,_,_,_,green,_,_,_,_]),
        right([_,_,_,_,red,_,_,_,_]),
        back([_,_,_,_,blue,_,_,_,_]),
        down([_,_,_,_,yellow,_,_,_,_])
    )
).

% ---------- Face tile lookup ----------

%           U
%   L       F       R       B
%           D
%
%   0 1 2
%   3 4 5
%   6 7 8
%
tile(up,    I, cube(up(U), left(_), front(_), right(_), back(_), down(_)), C) :- nth0(I, U, C).
tile(left,  I, cube(up(_), left(L), front(_), right(_), back(_), down(_)), C) :- nth0(I, L, C).
tile(front, I, cube(up(_), left(_), front(F), right(_), back(_), down(_)), C) :- nth0(I, F, C).
tile(right, I, cube(up(_), left(_), front(_), right(R), back(_), down(_)), C) :- nth0(I, R, C).
tile(back,  I, cube(up(_), left(_), front(_), right(_), back(B), down(_)), C) :- nth0(I, B, C).
tile(down,  I, cube(up(_), left(_), front(_), right(_), back(_), down(D)), C) :- nth0(I, D, C).

% ---------- Extract corners ----------

corner_ufr(Cube, [U, R, F]) :-
    tile(up, 8, Cube, U),
    tile(right, 0, Cube, R),
    tile(front, 2, Cube, F).

corner_urf(Cube, Corner) :-
    corner_ufr(Cube, Corner).

corner_ubr(Cube, [U, B, R]) :-
    tile(up, 2, Cube, U),
    tile(back, 0, Cube, B),
    tile(right, 2, Cube, R).

corner_ulb(Cube, [U, L, B]) :-
    tile(up, 0, Cube, U),
    tile(left, 0, Cube, L),
    tile(back, 2, Cube, B).

corner_ulf(Cube, [U, F, L]) :-
    tile(up, 6, Cube, U),
    tile(front, 0, Cube, F),
    tile(left, 2, Cube, L).

corner_dfr(Cube, [D, F, R]) :-
    tile(down, 2, Cube, D),
    tile(front, 8, Cube, F),
    tile(right, 6, Cube, R).

corner_drb(Cube, [D, R, B]) :-
    tile(down, 8, Cube, D),
    tile(right, 8, Cube, R),
    tile(back, 6, Cube, B).

corner_dbl(Cube, [D, B, L]) :-
    tile(down, 6, Cube, D),
    tile(back, 8, Cube, B),
    tile(left, 6, Cube, L).

corner_dlf(Cube, [D, L, F]) :-
    tile(down, 0, Cube, D),
    tile(left, 8, Cube, L),
    tile(front, 6, Cube, F).

corners(Cube, [
    ufr-UFR,
    ubr-UBR,
    ulb-ULB,
    ulf-ULF,
    dfr-DFR,
    drb-DRB,
    dbl-DBL,
    dlf-DLF
]) :-
    corner_ufr(Cube, UFR),
    corner_ubr(Cube, UBR),
    corner_ulb(Cube, ULB),
    corner_ulf(Cube, ULF),
    corner_dfr(Cube, DFR),
    corner_drb(Cube, DRB),
    corner_dbl(Cube, DBL),
    corner_dlf(Cube, DLF).

% ---------- Extract Edges ----------

edge_uf(Cube, [U, F]) :-
    tile(up, 7, Cube, U),
    tile(front, 1, Cube, F).

edge_ur(Cube, [U, R]) :-
    tile(up, 5, Cube, U),
    tile(right, 1, Cube, R).

edge_ub(Cube, [U, B]) :-
    tile(up, 1, Cube, U),
    tile(back, 1, Cube, B).

edge_ul(Cube, [U, L]) :-
    tile(up, 3, Cube, U),
    tile(left, 1, Cube, L).

edge_fr(Cube, [F, R]) :-
    tile(front, 5, Cube, F),
    tile(right, 3, Cube, R).

edge_rb(Cube, [R, B]) :-
    tile(right, 5, Cube, R),
    tile(back, 3, Cube, B).

edge_bl(Cube, [B, L]) :-
    tile(back, 5, Cube, B),
    tile(left, 3, Cube, L).

edge_lf(Cube, [L, F]) :-
    tile(left, 5, Cube, L),
    tile(front, 3, Cube, F).

edge_df(Cube, [D, F]) :-
    tile(down, 1, Cube, D),
    tile(front, 7, Cube, F).

edge_dr(Cube, [D, R]) :-
    tile(down, 5, Cube, D),
    tile(right, 7, Cube, R).

edge_db(Cube, [D, B]) :-
    tile(down, 7, Cube, D),
    tile(back, 7, Cube, B).

edge_dl(Cube, [D, L]) :-
    tile(down, 3, Cube, D),
    tile(left, 7, Cube, L).

edges(Cube, [
    uf-UF,
    ur-UR,
    ub-UB,
    ul-UL,
    fr-FR,
    rb-RB,
    bl-BL,
    lf-LF,
    df-DF,
    dr-DR,
    db-DB,
    dl-DL
]) :-
    edge_uf(Cube, UF),
    edge_ur(Cube, UR),
    edge_ub(Cube, UB),
    edge_ul(Cube, UL),
    edge_fr(Cube, FR),
    edge_rb(Cube, RB),
    edge_bl(Cube, BL),
    edge_lf(Cube, LF),
    edge_df(Cube, DF),
    edge_dr(Cube, DR),
    edge_db(Cube, DB),
    edge_dl(Cube, DL).

% ---------- Peice existance validation ----------

same_piece(A, B) :-
    sort(A, S),
    sort(B, S).

valid_corner_piece([white, green, red]).
valid_corner_piece([white, red, blue]).
valid_corner_piece([white, blue, orange]).
valid_corner_piece([white, orange, green]).
valid_corner_piece([yellow, green, red]).
valid_corner_piece([yellow, red, blue]).
valid_corner_piece([yellow, blue, orange]).
valid_corner_piece([yellow, orange, green]).

valid_edge_piece([white, green]).
valid_edge_piece([white, red]).
valid_edge_piece([white, blue]).
valid_edge_piece([white, orange]).
valid_edge_piece([green, red]).
valid_edge_piece([red, blue]).
valid_edge_piece([blue, orange]).
valid_edge_piece([orange, green]).
valid_edge_piece([yellow, green]).
valid_edge_piece([yellow, red]).
valid_edge_piece([yellow, blue]).
valid_edge_piece([yellow, orange]).

is_valid_corner_piece(C) :-
    valid_corner_piece(Expected),
    same_piece(C, Expected).

is_valid_edge_piece(E) :-
    valid_edge_piece(Expected),
    same_piece(E, Expected).

strip_labels([], []).
strip_labels([_-Piece | Rest], [Piece | Pieces]) :-
    strip_labels(Rest, Pieces).

all_valid_corners([]).
all_valid_corners([C | Rest]) :-
    is_valid_corner_piece(C),
    all_valid_corners(Rest).

all_valid_edges([]).
all_valid_edges([E | Rest]) :-
    is_valid_edge_piece(E),
    all_valid_edges(Rest).

canonical_piece(Piece, Canonical) :-
    sort(Piece, Canonical).

canonical_pieces([], []).
canonical_pieces([Piece | Rest], [Canonical | Canonicals]) :-
    canonical_piece(Piece, Canonical),
    canonical_pieces(Rest, Canonicals).

no_duplicate_pieces(Pieces) :-
    canonical_pieces(Pieces, Canonicals),
    sort(Canonicals, Unique),
    length(Canonicals, N),
    length(Unique, N).

valid_corner_pieces(Cube) :-
    corners(Cube, LabeledCorners),
    strip_labels(LabeledCorners, Corners),
    all_valid_corners(Corners),
    no_duplicate_pieces(Corners).

valid_edge_pieces(Cube) :-
    edges(Cube, LabeledEdges),
    strip_labels(LabeledEdges, Edges),
    all_valid_edges(Edges),
    no_duplicate_pieces(Edges).

valid_piece_existence(Cube) :-
    valid_corner_pieces(Cube),
    valid_edge_pieces(Cube).

% ---------- Canonical solved order ----------

solved_corners([
    [white, green, red],
    [white, blue, red],
    [white, orange, blue],
    [white, orange, green],
    [yellow, green, red],
    [yellow, red, blue],
    [yellow, blue, orange],
    [yellow, orange, green]
]).

solved_edges([
    [white, green],
    [white, red],
    [white, blue],
    [white, orange],
    [green, red],
    [red, blue],
    [blue, orange],
    [orange, green],
    [yellow, green],
    [yellow, red],
    [yellow, blue],
    [yellow, orange]
]).

piece_index(Piece, SolvedPieces, Index) :-
    canonical_piece(Piece, Canonical),
    piece_index_(Canonical, SolvedPieces, 0, Index).

piece_index_(Canonical, [Solved | _], Index, Index) :-
    canonical_piece(Solved, Canonical).

piece_index_(Canonical, [_ | Rest], Current, Index) :-
    Next is Current + 1,
    piece_index_(Canonical, Rest, Next, Index).

corner_permutation(Cube, Permutation) :-
    corners(Cube, LabeledCorners),
    strip_labels(LabeledCorners, Corners),
    solved_corners(SolvedCorners),
    pieces_permutation(Corners, SolvedCorners, Permutation).

edge_permutation(Cube, Permutation) :-
    edges(Cube, LabeledEdges),
    strip_labels(LabeledEdges, Edges),
    solved_edges(SolvedEdges),
    pieces_permutation(Edges, SolvedEdges, Permutation).

pieces_permutation([], _, []).

pieces_permutation([Piece | Rest], SolvedPieces, [Index | Indices]) :-
    piece_index(Piece, SolvedPieces, Index),
    pieces_permutation(Rest, SolvedPieces, Indices).

% ---------- Permutation parity ----------

inversion_count([], 0).

inversion_count([X | Rest], Count) :-
    count_smaller(X, Rest, SmallerCount),
    inversion_count(Rest, RestCount),
    Count is SmallerCount + RestCount.

count_smaller(_, [], 0).

count_smaller(X, [Y | Rest], Count) :-
    Y < X,
    count_smaller(X, Rest, RestCount),
    Count is RestCount + 1.

count_smaller(X, [Y | Rest], Count) :-
    Y >= X,
    count_smaller(X, Rest, Count).

permutation_parity(Permutation, Parity) :-
    inversion_count(Permutation, Count),
    Parity is Count mod 2.

valid_permutation_parity(Cube) :-
    corner_permutation(Cube, CornerPermutation),
    edge_permutation(Cube, EdgePermutation),
    permutation_parity(CornerPermutation, CornerParity),
    permutation_parity(EdgePermutation, EdgeParity),
    CornerParity =:= EdgeParity.

% ---------- Orientation Helpers ----------

ud_color(white).
ud_color(yellow).

fb_color(green).
fb_color(blue).

sum_list([], 0).
sum_list([X | Rest], Sum) :-
    sum_list(Rest, RestSum),
    Sum is X + RestSum.

% ---------- Catch twisted corner ----------

% Corner lists are extracted in slot order:
% [U/D sticker position, side sticker position, side sticker position]

% Orientation:
% 0 = white/yellow sticker is in position 0
% 1 = white/yellow sticker is in position 1
% 2 = white/yellow sticker is in position 2

corner_orientation(_Slot-Corner, Orientation) :-
    nth0(Orientation, Corner, Color),
    ud_color(Color).

corner_orientations([], []).

corner_orientations([LabeledCorner | Rest], [Orientation | Orientations]) :-
    corner_orientation(LabeledCorner, Orientation),
    corner_orientations(Rest, Orientations).

valid_corner_orientation(Cube) :-
    corners(Cube, LabeledCorners),
    corner_orientations(LabeledCorners, Orientations),
    sum_list(Orientations, Sum),
    0 is Sum mod 3.

% ---------- Catch flipped edge ----------

ud_face(up).
ud_face(down).

fb_face(front).
fb_face(back).

lr_face(left).
lr_face(right).

edge_slot_faces(uf, [up, front]).
edge_slot_faces(ur, [up, right]).
edge_slot_faces(ub, [up, back]).
edge_slot_faces(ul, [up, left]).

edge_slot_faces(fr, [front, right]).
edge_slot_faces(rb, [right, back]).
edge_slot_faces(bl, [back, left]).
edge_slot_faces(lf, [left, front]).

edge_slot_faces(df, [down, front]).
edge_slot_faces(dr, [down, right]).
edge_slot_faces(db, [down, back]).
edge_slot_faces(dl, [down, left]).

edge_has_fb_color([A, _]) :-
    fb_color(A),
    !.

edge_has_fb_color([_, B]) :-
    fb_color(B),
    !.

edge_has_ud_color([A, _]) :-
    ud_color(A),
    !.

edge_has_ud_color([_, B]) :-
    ud_color(B),
    !.

edge_orientation(Slot-Edge, 0) :-
    edge_has_ud_color(Edge),
    edge_slot_faces(Slot, Faces),
    edge_ud_sticker_on_ud_face(Edge, Faces),
    !.

edge_orientation(Slot-Edge, 0) :-
    \+ edge_has_ud_color(Edge),
    edge_has_fb_color(Edge),
    edge_slot_faces(Slot, Faces),
    edge_fb_sticker_on_fb_face(Edge, Faces),
    !.

edge_orientation(_Slot-_Edge, 1).

edge_fb_sticker_on_fb_face([Color | _], [Face | _]) :-
    fb_color(Color),
    fb_face(Face).

edge_fb_sticker_on_fb_face([_ | [Color]], [_ | [Face]]) :-
    fb_color(Color),
    fb_face(Face).

edge_ud_sticker_on_ud_face([Color | _], [Face | _]) :-
    ud_color(Color),
    ud_face(Face).

edge_ud_sticker_on_ud_face([_ | [Color]], [_ | [Face]]) :-
    ud_color(Color),
    ud_face(Face).

edge_orientations([], []).

edge_orientations([LabeledEdge | Rest], [Orientation | Orientations]) :-
    edge_orientation(LabeledEdge, Orientation),
    edge_orientations(Rest, Orientations).

valid_edge_orientation(Cube) :-
    edges(Cube, LabeledEdges),
    edge_orientations(LabeledEdges, Orientations),
    sum_list(Orientations, Sum),
    0 is Sum mod 2.

% ---------- Face rotation ---------

rotate_face_cw(
    [A,B,C,
     D,E,F,
     G,H,I],
    [G,D,A,
     H,E,B,
     I,F,C]
).

rotate_face_ccw(Face, Rotated) :-
    rotate_face_cw(Face, R1),
    rotate_face_cw(R1, R2),
    rotate_face_cw(R2, Rotated).

rotate_face_180(Face, Rotated) :-
    rotate_face_cw(Face, R1),
    rotate_face_cw(R1, Rotated).

% ---------- Moves ----------

% U move
% Clockwise turn of the Up face, viewed from above.
move(cube(up(U), left(L), front(F), right(R), back(B), down(D)),
    u,
    cube(up(U2), left(L2), front(F2), right(R2), back(B2), down(D))) :-

    rotate_face_cw(U, U2),

    L  = [L0,L1,L2a,L3,L4,L5,L6,L7,L8],
    F  = [F0,F1,F2a,F3,F4,F5,F6,F7,F8],
    R  = [R0,R1,R2a,R3,R4,R5,R6,R7,R8],
    B  = [B0,B1,B2a,B3,B4,B5,B6,B7,B8],

    % top rows cycle:
    % front <- right <- back <- left <- front
    F2 = [R0,R1,R2a,F3,F4,F5,F6,F7,F8],
    R2 = [B0,B1,B2a,R3,R4,R5,R6,R7,R8],
    B2 = [L0,L1,L2a,B3,B4,B5,B6,B7,B8],
    L2 = [F0,F1,F2a,L3,L4,L5,L6,L7,L8].

move(Cube, u2, Result) :-
    move(Cube, u, C1),
    move(C1, u, Result).

move(Cube, u_prime, Result) :-
    move(Cube, u, C1),
    move(C1, u, C2),
    move(C2, u, Result).

% D move
% Clockwise turn of the Down face, viewed from below.
move(
    cube(up(U), left(L), front(F), right(R), back(B), down(D)),
    d,
    cube(up(U), left(L2), front(F2), right(R2), back(B2), down(D2))
) :-
    rotate_face_cw(D, D2),

    L  = [L0,L1,L2a,L3,L4,L5,L6,L7,L8],
    F  = [F0,F1,F2a,F3,F4,F5,F6,F7,F8],
    R  = [R0,R1,R2a,R3,R4,R5,R6,R7,R8],
    B  = [B0,B1,B2a,B3,B4,B5,B6,B7,B8],

    F2 = [F0,F1,F2a,F3,F4,F5,L6,L7,L8],
    R2 = [R0,R1,R2a,R3,R4,R5,F6,F7,F8],
    B2 = [B0,B1,B2a,B3,B4,B5,R6,R7,R8],
    L2 = [L0,L1,L2a,L3,L4,L5,B6,B7,B8].

move(Cube, d2, Result) :-
    move(Cube, d, C1),
    move(C1, d, Result).

move(Cube, d_prime, Result) :-
    move(Cube, d, C1),
    move(C1, d, C2),
    move(C2, d, Result).

% F move
% Clockwise turn of the Front face, viewed from the front.
move(cube(up(U), left(L), front(F), right(R), back(B), down(D)),
    f,
    cube(up(U2), left(L2), front(F2), right(R2), back(B), down(D2))) :-

    rotate_face_cw(F, F2),

    U = [U0,U1,U2a,U3,U4,U5,U6,U7,U8],
    L = [L0,L1,L2a,L3,L4,L5,L6,L7,L8],
    R = [R0,R1,R2a,R3,R4,R5,R6,R7,R8],
    D = [D0,D1,D2a,D3,D4,D5,D6,D7,D8],

    % front ring cycle
    U2 = [U0,U1,U2a,U3,U4,U5,L8,L5,L2a],
    R2 = [U6,R1,R2a,U7,R4,R5,U8,R7,R8],
    D2 = [R6,R3,R0,D3,D4,D5,D6,D7,D8],
    L2 = [L0,L1,D0,L3,L4,D1,L6,L7,D2a].

move(Cube, f2, Result) :-
    move(Cube, f, C1),
    move(C1, f, Result).

move(Cube, f_prime, Result) :-
    move(Cube, f, C1),
    move(C1, f, C2),
    move(C2, f, Result).

% B move
% Clockwise turn of the Back face, viewed from the back.
move(
    cube(up(U), left(L), front(F), right(R), back(B), down(D)),
    b,
    cube(up(U2), left(L2), front(F), right(R2), back(B2), down(D2))
) :-
    rotate_face_cw(B, B2),

    U = [U0,U1,U2a,U3,U4,U5,U6,U7,U8],
    L = [L0,L1,L2a,L3,L4,L5,L6,L7,L8],
    R = [R0,R1,R2a,R3,R4,R5,R6,R7,R8],
    D = [D0,D1,D2a,D3,D4,D5,D6,D7,D8],

    U2 = [R2a,R5,R8,U3,U4,U5,U6,U7,U8],
    L2 = [U2a,L1,L2a,U1,L4,L5,U0,L7,L8],
    D2 = [D0,D1,D2a,D3,D4,D5,L0,L3,L6],
    R2 = [R0,R1,D8,R3,R4,D7,R6,R7,D6].

move(Cube, b2, Result) :-
    move(Cube, b, C1),
    move(C1, b, Result).

move(Cube, b_prime, Result) :-
    move(Cube, b, C1),
    move(C1, b, C2),
    move(C2, b, Result).

% R move
% Clockwise turn of the Right face, viewed from the right.
move(cube(up(U), left(L), front(F), right(R), back(B), down(D)),
    r,
    cube(up(U2), left(L), front(F2), right(R2), back(B2), down(D2))) :-

    rotate_face_cw(R, R2),

    U = [U0,U1,U2a,U3,U4,U5,U6,U7,U8],
    F = [F0,F1,F2a,F3,F4,F5,F6,F7,F8],
    B = [B0,B1,B2a,B3,B4,B5,B6,B7,B8],
    D = [D0,D1,D2a,D3,D4,D5,D6,D7,D8],

    U2 = [U0,U1,F2a,U3,U4,F5,U6,U7,F8],
    F2 = [F0,F1,D2a,F3,F4,D5,F6,F7,D8],
    D2 = [D0,D1,B6,D3,D4,B3,D6,D7,B0],
    B2 = [U8,B1,B2a,U5,B4,B5,U2a,B7,B8].

move(Cube, r2, Result) :-
    move(Cube, r, C1),
    move(C1, r, Result).

move(Cube, r_prime, Result) :-
    move(Cube, r, C1),
    move(C1, r, C2),
    move(C2, r, Result).

% L move
% Clockwise turn of the Left face, viewed from the left.
move(cube(up(U), left(L), front(F), right(R), back(B), down(D)),
    l,
    cube(up(U2), left(L2), front(F2), right(R), back(B2), down(D2))) :-

    rotate_face_cw(L, L2),

    U = [U0,U1,U2a,U3,U4,U5,U6,U7,U8],
    F = [F0,F1,F2a,F3,F4,F5,F6,F7,F8],
    B = [B0,B1,B2a,B3,B4,B5,B6,B7,B8],
    D = [D0,D1,D2a,D3,D4,D5,D6,D7,D8],

    U2 = [B8,U1,U2a,B5,U4,U5,B2a,U7,U8],
    F2 = [U0,F1,F2a,U3,F4,F5,U6,F7,F8],
    D2 = [F0,D1,D2a,F3,D4,D5,F6,D7,D8],
    B2 = [B0,B1,D6,B3,B4,D3,B6,B7,D0].

move(Cube, l2, Result) :-
    move(Cube, l, C1),
    move(C1, l, Result).

move(Cube, l_prime, Result) :-
    move(Cube, l, C1),
    move(C1, l, C2),
    move(C2, l, Result).

% ---------- Move list applicator ----------

apply_moves(Cube, [], Cube).

apply_moves(Cube, [Move | Rest], Result) :-
    move(Cube, Move, NextCube),
    apply_moves(NextCube, Rest, Result).

% ---------- Full move set definition ----------

basic_move(u).
basic_move(d).
basic_move(f).
basic_move(b).
basic_move(r).
basic_move(l).

move_name(u).
move_name(u_prime).
move_name(u2).

move_name(d).
move_name(d_prime).
move_name(d2).

move_name(f).
move_name(f_prime).
move_name(f2).

move_name(b).
move_name(b_prime).
move_name(b2).

move_name(r).
move_name(r_prime).
move_name(r2).

move_name(l).
move_name(l_prime).
move_name(l2).

% ---------- Solved state definition ----------

solved_cube(
    cube(
        up([white,white,white,white,white,white,white,white,white]),
        left([orange,orange,orange,orange,orange,orange,orange,orange,orange]),
        front([green,green,green,green,green,green,green,green,green]),
        right([red,red,red,red,red,red,red,red,red]),
        back([blue,blue,blue,blue,blue,blue,blue,blue,blue]),
        down([yellow,yellow,yellow,yellow,yellow,yellow,yellow,yellow,yellow])
    )
).

solved(Cube) :-
    solved_cube(Cube).

% ---------- Avoid obviously wasteful move sequences ----------

same_face(u, u).
same_face(u, u_prime).
same_face(u, u2).
same_face(u_prime, u).
same_face(u_prime, u_prime).
same_face(u_prime, u2).
same_face(u2, u).
same_face(u2, u_prime).
same_face(u2, u2).

same_face(d, d).
same_face(d, d_prime).
same_face(d, d2).
same_face(d_prime, d).
same_face(d_prime, d_prime).
same_face(d_prime, d2).
same_face(d2, d).
same_face(d2, d_prime).
same_face(d2, d2).

same_face(f, f).
same_face(f, f_prime).
same_face(f, f2).
same_face(f_prime, f).
same_face(f_prime, f_prime).
same_face(f_prime, f2).
same_face(f2, f).
same_face(f2, f_prime).
same_face(f2, f2).

same_face(b, b).
same_face(b, b_prime).
same_face(b, b2).
same_face(b_prime, b).
same_face(b_prime, b_prime).
same_face(b_prime, b2).
same_face(b2, b).
same_face(b2, b_prime).
same_face(b2, b2).

same_face(r, r).
same_face(r, r_prime).
same_face(r, r2).
same_face(r_prime, r).
same_face(r_prime, r_prime).
same_face(r_prime, r2).
same_face(r2, r).
same_face(r2, r_prime).
same_face(r2, r2).

same_face(l, l).
same_face(l, l_prime).
same_face(l, l2).
same_face(l_prime, l).
same_face(l_prime, l_prime).
same_face(l_prime, l2).
same_face(l2, l).
same_face(l2, l_prime).
same_face(l2, l2).

opposite_face(u, d).
opposite_face(d, u).

opposite_face(f, b).
opposite_face(b, f).

opposite_face(r, l).
opposite_face(l, r).

move_face(u, u).
move_face(u_prime, u).
move_face(u2, u).

move_face(d, d).
move_face(d_prime, d).
move_face(d2, d).

move_face(f, f).
move_face(f_prime, f).
move_face(f2, f).

move_face(b, b).
move_face(b_prime, b).
move_face(b2, b).

move_face(r, r).
move_face(r_prime, r).
move_face(r2, r).

move_face(l, l).
move_face(l_prime, l).
move_face(l2, l).

% Keep only one order for opposite faces.
% Allowed canonical order:
% u before d
% f before b
% r before l

canonical_opposite_order(u, d).
canonical_opposite_order(f, b).
canonical_opposite_order(r, l).

bad_opposite_order(PreviousMove, Move) :-
    move_face(PreviousMove, PreviousFace),
    move_face(Move, CurrentFace),
    opposite_face(PreviousFace, CurrentFace),
    \+ canonical_opposite_order(PreviousFace, CurrentFace).

valid_next_move(none, Move) :-
    move_name(Move).

valid_next_move(Previous, Move) :-
    move_name(Move),
    \+ same_face(Previous, Move),
    \+ bad_opposite_order(Previous, Move).

% ---------- Depth limited solver ----------

solve(Cube, Solution) :-
    structurally_valid_cube(Cube),
    between(0, 7, Depth),
    solve_depth(Cube, Depth, none, [Cube], Solution),
    !.

solve_depth(Cube, 0, _, _, []) :-
    solved(Cube).

solve_depth(Cube, Depth, PreviousMove, Visited, [Move | Rest]) :-
    Depth > 0,
    valid_next_move(PreviousMove, Move),
    move(Cube, Move, NextCube),
    \+ member(NextCube, Visited),
    NewDepth is Depth - 1,
    solve_depth(NextCube, NewDepth, Move, [NextCube | Visited], Rest).

valid_cube(Cube) :-
    structurally_valid_cube(Cube),
    valid_edge_orientation(Cube).

structurally_valid_cube(Cube) :-
    valid_face_lengths(Cube),
    valid_color_counts(Cube),
    valid_centers(Cube),
    valid_piece_existence(Cube),
    valid_permutation_parity(Cube),
    valid_corner_orientation(Cube).

% ---------- Browser-facing predicate ----------

check_cube(Cube, valid) :-
    structurally_valid_cube(Cube),
    !.

check_cube(_, invalid).

solve_cube(Cube, Solution) :-
    solve(Cube, Solution).
