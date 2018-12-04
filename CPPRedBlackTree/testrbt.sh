#!/bin/bash

file=testrbt.cpp

if [ ! -f "$file" ]; then
    echo -e "Error: File '$file' not found.\nTest failed."
    exit 1
fi

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
    received=$( $command $1 2>&1 | tr -d '\r' )
    if [ "$expected" = "$received" ]; then
        echo "success"
        (( ++num_right ))
    else
        echo -e "failure\n\nExpected$line\n$expected\nReceived$line\n$received\n"
    fi
}

run_test_args "" "Root is null."$'\n'$'\n'"Height:                   -1"$'\n'"Total nodes:              0"$'\n'"Leaf count:               0"$'\n'"Internal nodes:           0"$'\n'"Diameter:                 0"$'\n'"Maximum width:            0"$'\n'"Successful search cost:   0.000"$'\n'"Unsuccessful search cost: 0.000"$'\n'"Inorder traversal:        []"
run_test_args "50" "50"$'\n'$'\n'"Height:                   0"$'\n'"Total nodes:              1"$'\n'"Leaf count:               1"$'\n'"Internal nodes:           0"$'\n'"Diameter:                 0"$'\n'"Maximum width:            1"$'\n'"Successful search cost:   1.000"$'\n'"Unsuccessful search cost: 1.000"$'\n'"Inorder traversal:        [50]"
run_test_args "50 60" "50"$'\n'"  \\"$'\n'"  60"$'\n'$'\n'"Height:                   1"$'\n'"Total nodes:              2"$'\n'"Leaf count:               1"$'\n'"Internal nodes:           1"$'\n'"Diameter:                 1"$'\n'"Maximum width:            1"$'\n'"Successful search cost:   1.500"$'\n'"Unsuccessful search cost: 1.667"$'\n'"Inorder traversal:        [50, 60]"
run_test_args "50 60 70" " 60"$'\n'" / \\"$'\n'"50 70"$'\n'$'\n'"Height:                   1"$'\n'"Total nodes:              3"$'\n'"Leaf count:               2"$'\n'"Internal nodes:           1"$'\n'"Diameter:                 2"$'\n'"Maximum width:            2"$'\n'"Successful search cost:   1.667"$'\n'"Unsuccessful search cost: 2.000"$'\n'"Inorder traversal:        [50, 60, 70]"
run_test_args "50 60 70 40 30 20 50" "Warning: Attempt to insert duplicate key '50'."$'\n'"     60"$'\n'"     / \\"$'\n'"    40 70"$'\n'"   / \\"$'\n'"  30 50"$'\n'" /"$'\n'"20"$'\n'$'\n'"Height:                   3"$'\n'"Total nodes:              6"$'\n'"Leaf count:               3"$'\n'"Internal nodes:           3"$'\n'"Diameter:                 4"$'\n'"Maximum width:            2"$'\n'"Successful search cost:   2.500"$'\n'"Unsuccessful search cost: 3.000"$'\n'"Inorder traversal:        [20, 30, 40, 50, 60, 70]"
run_test_args "23 56 -8 90 25 18 42 99 -5" "     23"$'\n'"     / \\"$'\n'"    /   \\"$'\n'"   /     \\"$'\n'"  -5     56"$'\n'" / \\     / \\"$'\n'"-8 18   /   \\"$'\n'"       25   90"$'\n'"        \\     \\"$'\n'"        42    99"$'\n'$'\n'"Height:                   3"$'\n'"Total nodes:              9"$'\n'"Leaf count:               4"$'\n'"Internal nodes:           5"$'\n'"Diameter:                 5"$'\n'"Maximum width:            4"$'\n'"Successful search cost:   2.778"$'\n'"Unsuccessful search cost: 3.400"$'\n'"Inorder traversal:        [-8, -5, 18, 23, 25, 42, 56, 90, 99]"
run_test_args "109 17 12 452 19 123 581 49" "   17"$'\n'"   / \\"$'\n'"  12 109"$'\n'"     / \\"$'\n'"    /   \\"$'\n'"   /     \\"$'\n'"  19     452"$'\n'"   \\     / \\"$'\n'"   49  123 581"$'\n'$'\n'"Height:                   3"$'\n'"Total nodes:              8"$'\n'"Leaf count:               4"$'\n'"Internal nodes:           4"$'\n'"Diameter:                 4"$'\n'"Maximum width:            3"$'\n'"Successful search cost:   2.875"$'\n'"Unsuccessful search cost: 3.444"$'\n'"Inorder traversal:        [12, 17, 19, 49, 109, 123, 452, 581]"
run_test_args "Jim Connie Mike Michelle John Amy Bill Kyle Jill Mike Jill" "Warning: Attempt to insert duplicate key 'Mike'."$'\n'"Warning: Attempt to insert duplicate key 'Jill'."$'\n'"         Jim"$'\n'"         / \\"$'\n'"        /   \\"$'\n'"       /     \\"$'\n'"      /       \\"$'\n'"     /         \\"$'\n'"   Bill     Michelle"$'\n'"   / \\         / \\"$'\n'"  /   \\       /   \\"$'\n'"Amy Connie   /     \\"$'\n'"        \\  John   Mike"$'\n'"       Jill  \\"$'\n'"            Kyle"$'\n'$'\n'"Height:                   3"$'\n'"Total nodes:              9"$'\n'"Leaf count:               4"$'\n'"Internal nodes:           5"$'\n'"Diameter:                 6"$'\n'"Maximum width:            4"$'\n'"Successful search cost:   2.778"$'\n'"Unsuccessful search cost: 3.400"$'\n'"Inorder traversal:        [Amy, Bill, Connie, Jill, Jim, John, Kyle, Michelle, Mike]"
run_test_args "A Z B Y C X D W E V F U G T H S I R J Q K P L O M N" "              H"$'\n'"             / \\"$'\n'"            /   \\"$'\n'"           /     \\"$'\n'"          /       \\"$'\n'"         /         \\"$'\n'"        /           \\"$'\n'"       /             \\"$'\n'"      D               S"$'\n'"     / \\             / \\"$'\n'"    /   \\           /   \\"$'\n'"   /     \\         /     \\"$'\n'"  B       F       /       \\"$'\n'" / \\     / \\     /         \\"$'\n'"A   C   E   G   /           \\"$'\n'"               /             \\"$'\n'"              L               W"$'\n'"             / \\             / \\"$'\n'"            /   \\           /   \\"$'\n'"           /     \\         /     \\"$'\n'"          J       Q       U       Y"$'\n'"         / \\     / \\     / \\     / \\"$'\n'"        I   K   O   R   T   V   X   Z"$'\n'"               / \\"$'\n'"              M   P"$'\n'"               \\"$'\n'"                N"$'\n'$'\n'"Height:                   6"$'\n'"Total nodes:              26"$'\n'"Leaf count:               13"$'\n'"Internal nodes:           13"$'\n'"Diameter:                 9"$'\n'"Maximum width:            8"$'\n'"Successful search cost:   4.154"$'\n'"Unsuccessful search cost: 4.963"$'\n'"Inorder traversal:        [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z]"
run_test_args "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30" "              8"$'\n'"             / \\"$'\n'"            /   \\"$'\n'"           /     \\"$'\n'"          /       \\"$'\n'"         /         \\"$'\n'"        /           \\"$'\n'"       /             \\"$'\n'"      4              16"$'\n'"     / \\             / \\"$'\n'"    /   \\           /   \\"$'\n'"   /     \\         /     \\"$'\n'"  2       6       /       \\"$'\n'" / \\     / \\     /         \\"$'\n'"1   3   5   7   /           \\"$'\n'"               /             \\"$'\n'"              12             20"$'\n'"             / \\             / \\"$'\n'"            /   \\           /   \\"$'\n'"           /     \\         /     \\"$'\n'"          10     14       18     24"$'\n'"         / \\     / \\     / \\     / \\"$'\n'"        9  11   13 15   17 19   /   \\"$'\n'"                               /     \\"$'\n'"                              22     26"$'\n'"                             / \\     / \\"$'\n'"                            21 23   25 28"$'\n'"                                       / \\"$'\n'"                                      27 29"$'\n'"                                           \\"$'\n'"                                           30"$'\n'$'\n'"Height:                   7"$'\n'"Total nodes:              30"$'\n'"Leaf count:               15"$'\n'"Internal nodes:           15"$'\n'"Diameter:                 10"$'\n'"Maximum width:            8"$'\n'"Successful search cost:   4.500"$'\n'"Unsuccessful search cost: 5.323"$'\n'"Inorder traversal:        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]"
run_test_args "30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1" "                             23"$'\n'"                             / \\"$'\n'"                            /   \\"$'\n'"                           /     \\"$'\n'"                          /       \\"$'\n'"                         /         \\"$'\n'"                        /           \\"$'\n'"                       /             \\"$'\n'"                      15             27"$'\n'"                     / \\             / \\"$'\n'"                    /   \\           /   \\"$'\n'"                   /     \\         /     \\"$'\n'"                  /       \\       25     29"$'\n'"                 /         \\     / \\     / \\"$'\n'"                /           \\   24 26   28 30"$'\n'"               /             \\"$'\n'"              11             19"$'\n'"             / \\             / \\"$'\n'"            /   \\           /   \\"$'\n'"           /     \\         /     \\"$'\n'"          7      13       17     21"$'\n'"         / \\     / \\     / \\     / \\"$'\n'"        /   \\   12 14   16 18   20 22"$'\n'"       /     \\"$'\n'"      5       9"$'\n'"     / \\     / \\"$'\n'"    3   6   8  10"$'\n'"   / \\"$'\n'"  2   4"$'\n'" /"$'\n'"1"$'\n'$'\n'"Height:                   7"$'\n'"Total nodes:              30"$'\n'"Leaf count:               15"$'\n'"Internal nodes:           15"$'\n'"Diameter:                 10"$'\n'"Maximum width:            8"$'\n'"Successful search cost:   4.500"$'\n'"Unsuccessful search cost: 5.323"$'\n'"Inorder traversal:        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]"
run_test_args "Engling Borowski Duggan Naumann Damopoulos Wetzel Nicolosi Ateniese Bonelli Mordohai Klappholz Kleinberg Portokalidis Wang Compagnoni" "                  Duggan"$'\n'"                    / \\"$'\n'"                   /   \\"$'\n'"                  /     \\"$'\n'"                 /       \\"$'\n'"                /         \\"$'\n'"               /           \\"$'\n'"              /             \\"$'\n'"             /               \\"$'\n'"            /                 \\"$'\n'"           /                   \\"$'\n'"       Borowski              Naumann"$'\n'"         / \\                   / \\"$'\n'"        /   \\                 /   \\"$'\n'"       /     \\               /     \\"$'\n'"      /       \\             /       \\"$'\n'"     /         \\           /         \\"$'\n'"    /           \\         /           \\"$'\n'"Ateniese    Damopoulos   /             \\"$'\n'"    \\           /       /               \\"$'\n'"  Bonelli  Compagnoni  /                 \\"$'\n'"                      /                   \\"$'\n'"                 Klappholz           Portokalidis"$'\n'"                    / \\                   / \\"$'\n'"                   /   \\                 /   \\"$'\n'"                  /     \\               /     \\"$'\n'"                 /       \\             /       \\"$'\n'"                /         \\           /         \\"$'\n'"            Engling    Mordohai   Nicolosi    Wetzel"$'\n'"                          /                     /"$'\n'"                     Kleinberg                Wang"$'\n'$'\n'"Height:                   4"$'\n'"Total nodes:              15"$'\n'"Leaf count:               6"$'\n'"Internal nodes:           9"$'\n'"Diameter:                 7"$'\n'"Maximum width:            6"$'\n'"Successful search cost:   3.400"$'\n'"Unsuccessful search cost: 4.125"$'\n'"Inorder traversal:        [Ateniese, Bonelli, Borowski, Compagnoni, Damopoulos, Duggan, Engling, Klappholz, Kleinberg, Mordohai, Naumann, Nicolosi, Portokalidis, Wang, Wetzel]"

echo -e "\nTotal tests run: $total"
echo -e "Number correct : $num_right"
echo -n "Percent correct: "
echo "scale=2; 100 * $num_right / $total" | bc

if [ "$language" = "java" ]; then
    echo -e -n "\nRemoving class files..."
    rm -f *.class
    echo "done"
elif [ "$language" = "c" ]; then
    echo -e -n "\nCleaning project..."
    make clean > /dev/null 2>&1
    echo "done"
fi
