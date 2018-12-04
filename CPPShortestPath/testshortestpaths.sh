#!/bin/bash

file=shortestpaths.cpp

if [ ! -f "$file" ]; then
    echo -e "Error: File '$file' not found.\nTest failed."
    exit 1
fi

MAXTIME="1.000"
num_right=0
total=0
line="________________________________________________________________________"
compiler=
interpreter=
language=
extension=${file##*.}
if [ "$extension" = "py" ]; then
    if [ ! -z "$PYTHON_PATH" ]; then
        interpreter=$(which python.exe)
    else
        interpreter=$(which python3.2)
    fi
    command="$interpreter $file"
    echo -e "Testing $file\n"
elif [ "$extension" = "java" ]; then
    language="java"
    command="java ${file%.java}"
    echo -n "Compiling $file..."
    javac $file
    echo -e "done\n"
elif [ "$extension" = "c" ] || [ "$extension" = "cpp" ]; then
    language="c"
    command="./${file%.*}"
    echo -n "Compiling $file..."
    results=$(make 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "\n$results"
        exit 1
    fi
    echo -e "done\n"
fi

run_test_args() {
    (( ++total ))
    echo -n "Running test $total..."
    expected=$2
    local ismac=0
    date --version >/dev/null 2>&1
    if [ $? -ne 0 ]; then
       ismac=1
    fi
    local start=0
    if (( ismac )); then
        start=$(python -c 'import time; print time.time()')
    else
        start=$(date +%s.%N)
    fi
    received=$($command $1 2>&1 | tr -d '\r')
    local end=$(date +%s.%N)
    if (( ismac )); then
        end=$(python -c 'import time; print time.time()')
    else
        end=$(date +%s.%N)
    fi
    local elapsed=$(echo "scale=3; $end - $start" | bc | awk '{printf "%.3f", $0}') 
    if [ "$expected" != "$received" ]; then
        echo -e "failure\n\nExpected$line\n$expected\n"
        echo -e "Received$line\n$received\n"
    else
        result=$(echo $elapsed $MAXTIME | awk '{if ($1 > $2) print 1; else print 0}')
        if [ "$result" -eq 1 ]; then
            echo -e "failure\nTest timed out at $elapsed seconds. Maximum time allowed is $MAXTIME seconds.\n"
        else
            echo "success [$elapsed seconds]"
            (( ++num_right ))
        fi
    fi
}

# Test 1
run_test_args "" "Usage: ./shortestpaths <filename>"

# Test 2
run_test_args "notfound.txt" "Error: Cannot open file 'notfound.txt'."

# Test 3
(cat << ENDOFTEXT
0
X Y 1
Y Z 4
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Error: Invalid number of vertices '0' on line 1."
rm -f graph.txt

# Test 4
(cat << ENDOFTEXT
three
X Y 1
Y Z 4
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Error: Invalid number of vertices 'three' on line 1."
rm -f graph.txt

# Test 5
(cat << ENDOFTEXT
4
A C 2
A D 10
B A 7
B C
B D 1
C B 3
D A 2
D B 6
D C 6
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Error: Invalid edge data 'B C' on line 5."
rm -f graph.txt

# Test 6
(cat << ENDOFTEXT
3
X Y 1
Y Z 4
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Error: Starting vertex 'X' on line 2 is not among valid values A-C."
rm -f graph.txt

# Test 7
(cat << ENDOFTEXT
4
A C 2
A D 10
B A 7
B C 5
b D 1
C B 3
D A 2
D B 6
D C 6
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Error: Starting vertex 'b' on line 6 is not among valid values A-D."
rm -f graph.txt

# Test 8
(cat << ENDOFTEXT
4
A C 2
A D 10
B A 7
B C 5
Hoboken Weehawken 1
C B 3
D A 2
D B 6
D C 6
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Error: Starting vertex 'Hoboken' on line 6 is not among valid values A-D."
rm -f graph.txt

# Test 9
(cat << ENDOFTEXT
6
A C 2
A . 10
B A 7
B C 5
B D 1
C B 3
D A 2
D B 6
D C 6
E F 8
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Error: Ending vertex '.' on line 3 is not among valid values A-F."
rm -f graph.txt

# Test 10
(cat << ENDOFTEXT
4
A C 2
A D 10
B A 7
B C 5
B D 1
C B 3
D A 2
D B 6
D NYC 6
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Error: Ending vertex 'NYC' on line 10 is not among valid values A-D."
rm -f graph.txt

# Test 11
(cat << ENDOFTEXT
4
A C 2
A D 10
B A -7
B C 5
B D 1
C B 3
D A 2
D B 6
D C 6
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Error: Invalid edge weight '-7' on line 4."
rm -f graph.txt

# Test 12
(cat << ENDOFTEXT
4
A C 2
A D 10
B A 7
B C 5
B D 1
C B 3
D A 0
D B 6
D C 6
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Error: Invalid edge weight '0' on line 8."
rm -f graph.txt

# Test 13
(cat << ENDOFTEXT
4
A C 2
A D 10
B A 7
B C 5
B D 1
C B 3
D A 2
D B sixteen
D C 6
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Error: Invalid edge weight 'sixteen' on line 9."
rm -f graph.txt

# Test 14
(cat << ENDOFTEXT
1
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Distance matrix:"$'\n'"  A"$'\n'"A 0"$'\n'$'\n'"Path lengths:"$'\n'"  A"$'\n'"A 0"$'\n'$'\n'"Intermediate vertices:"$'\n'"  A"$'\n'"A -"$'\n'$'\n'"A -> A, distance: 0, path: A"
rm -f graph.txt

# Test 15
(cat << ENDOFTEXT
4
A C 2
A D 10
B A 7
B C 5
B D 1
C B 3
D A 2
D B 6
D C 6
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Distance matrix:"$'\n'"   A  B  C  D"$'\n'"A  0  -  2 10"$'\n'"B  7  0  5  1"$'\n'"C  -  3  0  -"$'\n'"D  2  6  6  0"$'\n'$'\n'"Path lengths:"$'\n'"  A B C D"$'\n'"A 0 5 2 6"$'\n'"B 3 0 5 1"$'\n'"C 6 3 0 4"$'\n'"D 2 6 4 0"$'\n'$'\n'"Intermediate vertices:"$'\n'"  A B C D"$'\n'"A - C - C"$'\n'"B D - - -"$'\n'"C D - - B"$'\n'"D - - A -"$'\n'$'\n'"A -> A, distance: 0, path: A"$'\n'"A -> B, distance: 5, path: A -> C -> B"$'\n'"A -> C, distance: 2, path: A -> C"$'\n'"A -> D, distance: 6, path: A -> C -> B -> D"$'\n'"B -> A, distance: 3, path: B -> D -> A"$'\n'"B -> B, distance: 0, path: B"$'\n'"B -> C, distance: 5, path: B -> C"$'\n'"B -> D, distance: 1, path: B -> D"$'\n'"C -> A, distance: 6, path: C -> B -> D -> A"$'\n'"C -> B, distance: 3, path: C -> B"$'\n'"C -> C, distance: 0, path: C"$'\n'"C -> D, distance: 4, path: C -> B -> D"$'\n'"D -> A, distance: 2, path: D -> A"$'\n'"D -> B, distance: 6, path: D -> B"$'\n'"D -> C, distance: 4, path: D -> A -> C"$'\n'"D -> D, distance: 0, path: D"
rm -f graph.txt

# Test 16
(cat << ENDOFTEXT
5
A C 2
A D 10
A E 13
B A 7
B C 5
B D 1
B E 5
C B 3
C D 4
D A 2
D B 6
D C 6
D E 8
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Distance matrix:"$'\n'"   A  B  C  D  E"$'\n'"A  0  -  2 10 13"$'\n'"B  7  0  5  1  5"$'\n'"C  -  3  0  4  -"$'\n'"D  2  6  6  0  8"$'\n'"E  -  -  -  -  0"$'\n'$'\n'"Path lengths:"$'\n'"   A  B  C  D  E"$'\n'"A  0  5  2  6 10"$'\n'"B  3  0  5  1  5"$'\n'"C  6  3  0  4  8"$'\n'"D  2  6  4  0  8"$'\n'"E  -  -  -  -  0"$'\n'$'\n'"Intermediate vertices:"$'\n'"  A B C D E"$'\n'"A - C - C C"$'\n'"B D - - - -"$'\n'"C D - - - B"$'\n'"D - - A - -"$'\n'"E - - - - -"$'\n'$'\n'"A -> A, distance: 0, path: A"$'\n'"A -> B, distance: 5, path: A -> C -> B"$'\n'"A -> C, distance: 2, path: A -> C"$'\n'"A -> D, distance: 6, path: A -> C -> D"$'\n'"A -> E, distance: 10, path: A -> C -> B -> E"$'\n'"B -> A, distance: 3, path: B -> D -> A"$'\n'"B -> B, distance: 0, path: B"$'\n'"B -> C, distance: 5, path: B -> C"$'\n'"B -> D, distance: 1, path: B -> D"$'\n'"B -> E, distance: 5, path: B -> E"$'\n'"C -> A, distance: 6, path: C -> D -> A"$'\n'"C -> B, distance: 3, path: C -> B"$'\n'"C -> C, distance: 0, path: C"$'\n'"C -> D, distance: 4, path: C -> D"$'\n'"C -> E, distance: 8, path: C -> B -> E"$'\n'"D -> A, distance: 2, path: D -> A"$'\n'"D -> B, distance: 6, path: D -> B"$'\n'"D -> C, distance: 4, path: D -> A -> C"$'\n'"D -> D, distance: 0, path: D"$'\n'"D -> E, distance: 8, path: D -> E"$'\n'"E -> A, distance: infinity, path: none"$'\n'"E -> B, distance: infinity, path: none"$'\n'"E -> C, distance: infinity, path: none"$'\n'"E -> D, distance: infinity, path: none"$'\n'"E -> E, distance: 0, path: E"
rm -f graph.txt

# Test 17
(cat << ENDOFTEXT
5
A C 2
A E 13
B A 7
B C 5
B D 2147483647
B E 5
C B 3
D A 2
D B 6
D C 6
D E 8
E B 2147483647
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Distance matrix:"$'\n'"           A          B          C          D          E"$'\n'"A          0          -          2          -         13"$'\n'"B          7          0          5 2147483647          5"$'\n'"C          -          3          0          -          -"$'\n'"D          2          6          6          0          8"$'\n'"E          - 2147483647          -          -          0"$'\n'$'\n'"Path lengths:"$'\n'"           A          B          C          D          E"$'\n'"A          0          5          2 2147483652         10"$'\n'"B          7          0          5 2147483647          5"$'\n'"C         10          3          0 2147483650          8"$'\n'"D          2          6          4          0          8"$'\n'"E 2147483654 2147483647 2147483652 4294967294          0"$'\n'$'\n'"Intermediate vertices:"$'\n'"  A B C D E"$'\n'"A - C - C C"$'\n'"B - - - - -"$'\n'"C B - - B B"$'\n'"D - - A - -"$'\n'"E B - B B -"$'\n'$'\n'"A -> A, distance: 0, path: A"$'\n'"A -> B, distance: 5, path: A -> C -> B"$'\n'"A -> C, distance: 2, path: A -> C"$'\n'"A -> D, distance: 2147483652, path: A -> C -> B -> D"$'\n'"A -> E, distance: 10, path: A -> C -> B -> E"$'\n'"B -> A, distance: 7, path: B -> A"$'\n'"B -> B, distance: 0, path: B"$'\n'"B -> C, distance: 5, path: B -> C"$'\n'"B -> D, distance: 2147483647, path: B -> D"$'\n'"B -> E, distance: 5, path: B -> E"$'\n'"C -> A, distance: 10, path: C -> B -> A"$'\n'"C -> B, distance: 3, path: C -> B"$'\n'"C -> C, distance: 0, path: C"$'\n'"C -> D, distance: 2147483650, path: C -> B -> D"$'\n'"C -> E, distance: 8, path: C -> B -> E"$'\n'"D -> A, distance: 2, path: D -> A"$'\n'"D -> B, distance: 6, path: D -> B"$'\n'"D -> C, distance: 4, path: D -> A -> C"$'\n'"D -> D, distance: 0, path: D"$'\n'"D -> E, distance: 8, path: D -> E"$'\n'"E -> A, distance: 2147483654, path: E -> B -> A"$'\n'"E -> B, distance: 2147483647, path: E -> B"$'\n'"E -> C, distance: 2147483652, path: E -> B -> C"$'\n'"E -> D, distance: 4294967294, path: E -> B -> D"$'\n'"E -> E, distance: 0, path: E"
rm -f graph.txt

# Test 18
(cat << ENDOFTEXT
7
A B 11
A D 13
B A 7
B C 4
D E 8
D G 9
E A 9
E F 10
E G 2
F B 12
F C 19
G E 29
G C 5
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Distance matrix:"$'\n'"   A  B  C  D  E  F  G"$'\n'"A  0 11  - 13  -  -  -"$'\n'"B  7  0  4  -  -  -  -"$'\n'"C  -  -  0  -  -  -  -"$'\n'"D  -  -  -  0  8  -  9"$'\n'"E  9  -  -  -  0 10  2"$'\n'"F  - 12 19  -  -  0  -"$'\n'"G  -  -  5  - 29  -  0"$'\n'$'\n'"Path lengths:"$'\n'"   A  B  C  D  E  F  G"$'\n'"A  0 11 15 13 21 31 22"$'\n'"B  7  0  4 20 28 38 29"$'\n'"C  -  -  0  -  -  -  -"$'\n'"D 17 28 14  0  8 18  9"$'\n'"E  9 20  7 22  0 10  2"$'\n'"F 19 12 16 32 40  0 41"$'\n'"G 38 49  5 51 29 39  0"$'\n'$'\n'"Intermediate vertices:"$'\n'"  A B C D E F G"$'\n'"A - - B - D E D"$'\n'"B - - - A D E D"$'\n'"C - - - - - - -"$'\n'"D E E G - - E -"$'\n'"E - A G A - - -"$'\n'"F B - B B D - D"$'\n'"G E E - E - E -"$'\n'$'\n'"A -> A, distance: 0, path: A"$'\n'"A -> B, distance: 11, path: A -> B"$'\n'"A -> C, distance: 15, path: A -> B -> C"$'\n'"A -> D, distance: 13, path: A -> D"$'\n'"A -> E, distance: 21, path: A -> D -> E"$'\n'"A -> F, distance: 31, path: A -> D -> E -> F"$'\n'"A -> G, distance: 22, path: A -> D -> G"$'\n'"B -> A, distance: 7, path: B -> A"$'\n'"B -> B, distance: 0, path: B"$'\n'"B -> C, distance: 4, path: B -> C"$'\n'"B -> D, distance: 20, path: B -> A -> D"$'\n'"B -> E, distance: 28, path: B -> A -> D -> E"$'\n'"B -> F, distance: 38, path: B -> A -> D -> E -> F"$'\n'"B -> G, distance: 29, path: B -> A -> D -> G"$'\n'"C -> A, distance: infinity, path: none"$'\n'"C -> B, distance: infinity, path: none"$'\n'"C -> C, distance: 0, path: C"$'\n'"C -> D, distance: infinity, path: none"$'\n'"C -> E, distance: infinity, path: none"$'\n'"C -> F, distance: infinity, path: none"$'\n'"C -> G, distance: infinity, path: none"$'\n'"D -> A, distance: 17, path: D -> E -> A"$'\n'"D -> B, distance: 28, path: D -> E -> A -> B"$'\n'"D -> C, distance: 14, path: D -> G -> C"$'\n'"D -> D, distance: 0, path: D"$'\n'"D -> E, distance: 8, path: D -> E"$'\n'"D -> F, distance: 18, path: D -> E -> F"$'\n'"D -> G, distance: 9, path: D -> G"$'\n'"E -> A, distance: 9, path: E -> A"$'\n'"E -> B, distance: 20, path: E -> A -> B"$'\n'"E -> C, distance: 7, path: E -> G -> C"$'\n'"E -> D, distance: 22, path: E -> A -> D"$'\n'"E -> E, distance: 0, path: E"$'\n'"E -> F, distance: 10, path: E -> F"$'\n'"E -> G, distance: 2, path: E -> G"$'\n'"F -> A, distance: 19, path: F -> B -> A"$'\n'"F -> B, distance: 12, path: F -> B"$'\n'"F -> C, distance: 16, path: F -> B -> C"$'\n'"F -> D, distance: 32, path: F -> B -> A -> D"$'\n'"F -> E, distance: 40, path: F -> B -> A -> D -> E"$'\n'"F -> F, distance: 0, path: F"$'\n'"F -> G, distance: 41, path: F -> B -> A -> D -> G"$'\n'"G -> A, distance: 38, path: G -> E -> A"$'\n'"G -> B, distance: 49, path: G -> E -> A -> B"$'\n'"G -> C, distance: 5, path: G -> C"$'\n'"G -> D, distance: 51, path: G -> E -> A -> D"$'\n'"G -> E, distance: 29, path: G -> E"$'\n'"G -> F, distance: 39, path: G -> E -> F"$'\n'"G -> G, distance: 0, path: G"
rm -f graph.txt

# Test 19
(cat << ENDOFTEXT
8
A B 11
A D 13
B A 7
B C 4
B H 33
C A 8
C B 18
C E 22
D E 8
D G 9
E A 9
E F 10
E G 2
F B 12
F C 19
G E 29
G C 5
H A 1
H B 4
H D 9
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Distance matrix:"$'\n'"   A  B  C  D  E  F  G  H"$'\n'"A  0 11  - 13  -  -  -  -"$'\n'"B  7  0  4  -  -  -  - 33"$'\n'"C  8 18  0  - 22  -  -  -"$'\n'"D  -  -  -  0  8  -  9  -"$'\n'"E  9  -  -  -  0 10  2  -"$'\n'"F  - 12 19  -  -  0  -  -"$'\n'"G  -  -  5  - 29  -  0  -"$'\n'"H  1  4  -  9  -  -  -  0"$'\n'$'\n'"Path lengths:"$'\n'"   A  B  C  D  E  F  G  H"$'\n'"A  0 11 15 13 21 31 22 44"$'\n'"B  7  0  4 20 26 36 28 33"$'\n'"C  8 18  0 21 22 32 24 51"$'\n'"D 17 28 14  0  8 18  9 61"$'\n'"E  9 20  7 22  0 10  2 53"$'\n'"F 19 12 16 32 38  0 40 45"$'\n'"G 13 23  5 26 27 37  0 56"$'\n'"H  1  4  8  9 17 27 18  0"$'\n'$'\n'"Intermediate vertices:"$'\n'"  A B C D E F G H"$'\n'"A - - B - D E D B"$'\n'"B - - - A C E E -"$'\n'"C - - - A - E E B"$'\n'"D E E G - - E - E"$'\n'"E - A G A - - - B"$'\n'"F B - B B C - E B"$'\n'"G C C - C C E - C"$'\n'"H - - B - D E D -"$'\n'$'\n'"A -> A, distance: 0, path: A"$'\n'"A -> B, distance: 11, path: A -> B"$'\n'"A -> C, distance: 15, path: A -> B -> C"$'\n'"A -> D, distance: 13, path: A -> D"$'\n'"A -> E, distance: 21, path: A -> D -> E"$'\n'"A -> F, distance: 31, path: A -> D -> E -> F"$'\n'"A -> G, distance: 22, path: A -> D -> G"$'\n'"A -> H, distance: 44, path: A -> B -> H"$'\n'"B -> A, distance: 7, path: B -> A"$'\n'"B -> B, distance: 0, path: B"$'\n'"B -> C, distance: 4, path: B -> C"$'\n'"B -> D, distance: 20, path: B -> A -> D"$'\n'"B -> E, distance: 26, path: B -> C -> E"$'\n'"B -> F, distance: 36, path: B -> C -> E -> F"$'\n'"B -> G, distance: 28, path: B -> C -> E -> G"$'\n'"B -> H, distance: 33, path: B -> H"$'\n'"C -> A, distance: 8, path: C -> A"$'\n'"C -> B, distance: 18, path: C -> B"$'\n'"C -> C, distance: 0, path: C"$'\n'"C -> D, distance: 21, path: C -> A -> D"$'\n'"C -> E, distance: 22, path: C -> E"$'\n'"C -> F, distance: 32, path: C -> E -> F"$'\n'"C -> G, distance: 24, path: C -> E -> G"$'\n'"C -> H, distance: 51, path: C -> B -> H"$'\n'"D -> A, distance: 17, path: D -> E -> A"$'\n'"D -> B, distance: 28, path: D -> E -> A -> B"$'\n'"D -> C, distance: 14, path: D -> G -> C"$'\n'"D -> D, distance: 0, path: D"$'\n'"D -> E, distance: 8, path: D -> E"$'\n'"D -> F, distance: 18, path: D -> E -> F"$'\n'"D -> G, distance: 9, path: D -> G"$'\n'"D -> H, distance: 61, path: D -> E -> A -> B -> H"$'\n'"E -> A, distance: 9, path: E -> A"$'\n'"E -> B, distance: 20, path: E -> A -> B"$'\n'"E -> C, distance: 7, path: E -> G -> C"$'\n'"E -> D, distance: 22, path: E -> A -> D"$'\n'"E -> E, distance: 0, path: E"$'\n'"E -> F, distance: 10, path: E -> F"$'\n'"E -> G, distance: 2, path: E -> G"$'\n'"E -> H, distance: 53, path: E -> A -> B -> H"$'\n'"F -> A, distance: 19, path: F -> B -> A"$'\n'"F -> B, distance: 12, path: F -> B"$'\n'"F -> C, distance: 16, path: F -> B -> C"$'\n'"F -> D, distance: 32, path: F -> B -> A -> D"$'\n'"F -> E, distance: 38, path: F -> B -> C -> E"$'\n'"F -> F, distance: 0, path: F"$'\n'"F -> G, distance: 40, path: F -> B -> C -> E -> G"$'\n'"F -> H, distance: 45, path: F -> B -> H"$'\n'"G -> A, distance: 13, path: G -> C -> A"$'\n'"G -> B, distance: 23, path: G -> C -> B"$'\n'"G -> C, distance: 5, path: G -> C"$'\n'"G -> D, distance: 26, path: G -> C -> A -> D"$'\n'"G -> E, distance: 27, path: G -> C -> E"$'\n'"G -> F, distance: 37, path: G -> C -> E -> F"$'\n'"G -> G, distance: 0, path: G"$'\n'"G -> H, distance: 56, path: G -> C -> B -> H"$'\n'"H -> A, distance: 1, path: H -> A"$'\n'"H -> B, distance: 4, path: H -> B"$'\n'"H -> C, distance: 8, path: H -> B -> C"$'\n'"H -> D, distance: 9, path: H -> D"$'\n'"H -> E, distance: 17, path: H -> D -> E"$'\n'"H -> F, distance: 27, path: H -> D -> E -> F"$'\n'"H -> G, distance: 18, path: H -> D -> G"$'\n'"H -> H, distance: 0, path: H"
rm -f graph.txt

# Test 20
(cat << ENDOFTEXT
10
A B 111
A D 113
B A 17
B C 14
B H 133
B J 90
C A 8
C B 118
C E 22
D E 8
D G 19
D I 15
E A 19
E F 110
E G 2
F B 12
F C 119
G E 129
G C 5
H A 11
H B 14
H D 19
I A 23
I G 9
I H 77
J B 112
J D 83
J F 54
J I 18
ENDOFTEXT
) > graph.txt
run_test_args "graph.txt" "Distance matrix:"$'\n'"    A   B   C   D   E   F   G   H   I   J"$'\n'"A   0 111   - 113   -   -   -   -   -   -"$'\n'"B  17   0  14   -   -   -   - 133   -  90"$'\n'"C   8 118   0   -  22   -   -   -   -   -"$'\n'"D   -   -   -   0   8   -  19   -  15   -"$'\n'"E  19   -   -   -   0 110   2   -   -   -"$'\n'"F   -  12 119   -   -   0   -   -   -   -"$'\n'"G   -   -   5   - 129   -   0   -   -   -"$'\n'"H  11  14   -  19   -   -   -   0   -   -"$'\n'"I  23   -   -   -   -   -   9  77   0   -"$'\n'"J   - 112   -  83   -  54   -   -  18   0"$'\n'$'\n'"Path lengths:"$'\n'"    A   B   C   D   E   F   G   H   I   J"$'\n'"A   0 111 125 113 121 231 123 205 128 201"$'\n'"B  17   0  14 130  36 144  38 133 108  90"$'\n'"C   8 118   0 121  22 132  24 213 136 208"$'\n'"D  23 106  15   0   8 118  10  92  15 196"$'\n'"E  15 122   7 128   0 110   2 220 143 212"$'\n'"F  29  12  26 142  48   0  50 145 120 102"$'\n'"G  13 123   5 126  27 137   0 218 141 213"$'\n'"H  11  14  28  19  27 137  29   0  34 104"$'\n'"I  22  91  14  96  36 146   9  77   0 181"$'\n'"J  40  66  32  83  54  54  27  95  18   0"$'\n'$'\n'"Intermediate vertices:"$'\n'"   A  B  C  D  E  F  G  H  I  J"$'\n'"A  -  -  B  -  D  E  E  I  D  B"$'\n'"B  -  -  -  A  C  J  E  -  J  -"$'\n'"C  -  -  -  A  -  E  E  I  D  B"$'\n'"D  G  I  G  -  -  E  E  I  -  I"$'\n'"E  G  F  G  G  -  -  -  I  G  F"$'\n'"F  B  -  B  B  C  -  E  B  J  B"$'\n'"G  C  C  -  C  C  E  -  I  D  C"$'\n'"H  -  -  B  -  D  E  E  -  D  B"$'\n'"I  G  H  G  H  G  G  -  -  -  H"$'\n'"J  I  F  I  -  I  -  I  I  -  -"$'\n'$'\n'"A -> A, distance: 0, path: A"$'\n'"A -> B, distance: 111, path: A -> B"$'\n'"A -> C, distance: 125, path: A -> B -> C"$'\n'"A -> D, distance: 113, path: A -> D"$'\n'"A -> E, distance: 121, path: A -> D -> E"$'\n'"A -> F, distance: 231, path: A -> D -> E -> F"$'\n'"A -> G, distance: 123, path: A -> D -> E -> G"$'\n'"A -> H, distance: 205, path: A -> D -> I -> H"$'\n'"A -> I, distance: 128, path: A -> D -> I"$'\n'"A -> J, distance: 201, path: A -> B -> J"$'\n'"B -> A, distance: 17, path: B -> A"$'\n'"B -> B, distance: 0, path: B"$'\n'"B -> C, distance: 14, path: B -> C"$'\n'"B -> D, distance: 130, path: B -> A -> D"$'\n'"B -> E, distance: 36, path: B -> C -> E"$'\n'"B -> F, distance: 144, path: B -> J -> F"$'\n'"B -> G, distance: 38, path: B -> C -> E -> G"$'\n'"B -> H, distance: 133, path: B -> H"$'\n'"B -> I, distance: 108, path: B -> J -> I"$'\n'"B -> J, distance: 90, path: B -> J"$'\n'"C -> A, distance: 8, path: C -> A"$'\n'"C -> B, distance: 118, path: C -> B"$'\n'"C -> C, distance: 0, path: C"$'\n'"C -> D, distance: 121, path: C -> A -> D"$'\n'"C -> E, distance: 22, path: C -> E"$'\n'"C -> F, distance: 132, path: C -> E -> F"$'\n'"C -> G, distance: 24, path: C -> E -> G"$'\n'"C -> H, distance: 213, path: C -> A -> D -> I -> H"$'\n'"C -> I, distance: 136, path: C -> A -> D -> I"$'\n'"C -> J, distance: 208, path: C -> B -> J"$'\n'"D -> A, distance: 23, path: D -> E -> G -> C -> A"$'\n'"D -> B, distance: 106, path: D -> I -> H -> B"$'\n'"D -> C, distance: 15, path: D -> E -> G -> C"$'\n'"D -> D, distance: 0, path: D"$'\n'"D -> E, distance: 8, path: D -> E"$'\n'"D -> F, distance: 118, path: D -> E -> F"$'\n'"D -> G, distance: 10, path: D -> E -> G"$'\n'"D -> H, distance: 92, path: D -> I -> H"$'\n'"D -> I, distance: 15, path: D -> I"$'\n'"D -> J, distance: 196, path: D -> I -> H -> B -> J"$'\n'"E -> A, distance: 15, path: E -> G -> C -> A"$'\n'"E -> B, distance: 122, path: E -> F -> B"$'\n'"E -> C, distance: 7, path: E -> G -> C"$'\n'"E -> D, distance: 128, path: E -> G -> C -> A -> D"$'\n'"E -> E, distance: 0, path: E"$'\n'"E -> F, distance: 110, path: E -> F"$'\n'"E -> G, distance: 2, path: E -> G"$'\n'"E -> H, distance: 220, path: E -> G -> C -> A -> D -> I -> H"$'\n'"E -> I, distance: 143, path: E -> G -> C -> A -> D -> I"$'\n'"E -> J, distance: 212, path: E -> F -> B -> J"$'\n'"F -> A, distance: 29, path: F -> B -> A"$'\n'"F -> B, distance: 12, path: F -> B"$'\n'"F -> C, distance: 26, path: F -> B -> C"$'\n'"F -> D, distance: 142, path: F -> B -> A -> D"$'\n'"F -> E, distance: 48, path: F -> B -> C -> E"$'\n'"F -> F, distance: 0, path: F"$'\n'"F -> G, distance: 50, path: F -> B -> C -> E -> G"$'\n'"F -> H, distance: 145, path: F -> B -> H"$'\n'"F -> I, distance: 120, path: F -> B -> J -> I"$'\n'"F -> J, distance: 102, path: F -> B -> J"$'\n'"G -> A, distance: 13, path: G -> C -> A"$'\n'"G -> B, distance: 123, path: G -> C -> B"$'\n'"G -> C, distance: 5, path: G -> C"$'\n'"G -> D, distance: 126, path: G -> C -> A -> D"$'\n'"G -> E, distance: 27, path: G -> C -> E"$'\n'"G -> F, distance: 137, path: G -> C -> E -> F"$'\n'"G -> G, distance: 0, path: G"$'\n'"G -> H, distance: 218, path: G -> C -> A -> D -> I -> H"$'\n'"G -> I, distance: 141, path: G -> C -> A -> D -> I"$'\n'"G -> J, distance: 213, path: G -> C -> B -> J"$'\n'"H -> A, distance: 11, path: H -> A"$'\n'"H -> B, distance: 14, path: H -> B"$'\n'"H -> C, distance: 28, path: H -> B -> C"$'\n'"H -> D, distance: 19, path: H -> D"$'\n'"H -> E, distance: 27, path: H -> D -> E"$'\n'"H -> F, distance: 137, path: H -> D -> E -> F"$'\n'"H -> G, distance: 29, path: H -> D -> E -> G"$'\n'"H -> H, distance: 0, path: H"$'\n'"H -> I, distance: 34, path: H -> D -> I"$'\n'"H -> J, distance: 104, path: H -> B -> J"$'\n'"I -> A, distance: 22, path: I -> G -> C -> A"$'\n'"I -> B, distance: 91, path: I -> H -> B"$'\n'"I -> C, distance: 14, path: I -> G -> C"$'\n'"I -> D, distance: 96, path: I -> H -> D"$'\n'"I -> E, distance: 36, path: I -> G -> C -> E"$'\n'"I -> F, distance: 146, path: I -> G -> C -> E -> F"$'\n'"I -> G, distance: 9, path: I -> G"$'\n'"I -> H, distance: 77, path: I -> H"$'\n'"I -> I, distance: 0, path: I"$'\n'"I -> J, distance: 181, path: I -> H -> B -> J"$'\n'"J -> A, distance: 40, path: J -> I -> G -> C -> A"$'\n'"J -> B, distance: 66, path: J -> F -> B"$'\n'"J -> C, distance: 32, path: J -> I -> G -> C"$'\n'"J -> D, distance: 83, path: J -> D"$'\n'"J -> E, distance: 54, path: J -> I -> G -> C -> E"$'\n'"J -> F, distance: 54, path: J -> F"$'\n'"J -> G, distance: 27, path: J -> I -> G"$'\n'"J -> H, distance: 95, path: J -> I -> H"$'\n'"J -> I, distance: 18, path: J -> I"$'\n'"J -> J, distance: 0, path: J"
rm -f graph.txt

echo -e "\nTotal tests run: $total"
echo -e "Number correct : $num_right"
echo -n "Percent correct: "
echo "scale=2; 100 * $num_right / $total" | bc

if [ "$language" = "java" ]; then
    echo -e -n "\nRemoving class files..."
    rm -f *.class
    echo "done"
elif [ $language = "c" ]; then
    echo -e -n "\nCleaning project..."
    make clean > /dev/null 2>&1
    echo "done"
fi
