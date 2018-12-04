#!/bin/bash

file=testgraph.cpp

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

rm -rf graph.txt

(cat << ENDOFTEXT
1 1
ENDOFTEXT
) > graph.txt
run_test_args "unweighted bfs graph.txt" "1 -> [1]"$'\n'"Breadth-first search: 1"
run_test_args "unweighted dfs graph.txt" "1 -> [1]"$'\n'"Depth-first search: 1"
rm -rf graph.txt

(cat << ENDOFTEXT
1 2
1 3
2 4
3 4
ENDOFTEXT
) > graph.txt
run_test_args "unweighted bfs graph.txt" "1 -> [2, 3]"$'\n'"2 -> [1, 4]"$'\n'"3 -> [1, 4]"$'\n'"4 -> [2, 3]"$'\n'"Breadth-first search: 1 2 3 4"
run_test_args "unweighted dfs graph.txt" "1 -> [2, 3]"$'\n'"2 -> [1, 4]"$'\n'"3 -> [1, 4]"$'\n'"4 -> [2, 3]"$'\n'"Depth-first search: 1 2 4 3"
rm -rf graph.txt

(cat << ENDOFTEXT
1 2
1 3
2 4
3 5
ENDOFTEXT
) > graph.txt
run_test_args "unweighted bfs graph.txt" "1 -> [2, 3]"$'\n'"2 -> [1, 4]"$'\n'"3 -> [1, 5]"$'\n'"4 -> [2]"$'\n'"5 -> [3]"$'\n'"Breadth-first search: 1 2 3 4 5"
run_test_args "unweighted dfs graph.txt" "1 -> [2, 3]"$'\n'"2 -> [1, 4]"$'\n'"3 -> [1, 5]"$'\n'"4 -> [2]"$'\n'"5 -> [3]"$'\n'"Depth-first search: 1 2 4 3 5"
rm -rf graph.txt

(cat << ENDOFTEXT
1 3
1 4
1 5
2 5
2 6
3 4
3 6
5 6
7 8
7 10
8 9
9 10
ENDOFTEXT
) > graph.txt
run_test_args "unweighted bfs graph.txt" " 1 -> [3, 4, 5]"$'\n'" 2 -> [5, 6]"$'\n'" 3 -> [1, 4, 6]"$'\n'" 4 -> [1, 3]"$'\n'" 5 -> [1, 2, 6]"$'\n'" 6 -> [2, 3, 5]"$'\n'" 7 -> [8, 10]"$'\n'" 8 -> [7, 9]"$'\n'" 9 -> [8, 10]"$'\n'"10 -> [7, 9]"$'\n'"Breadth-first search: 1 3 4 5 6 2 7 8 10 9"
run_test_args "unweighted dfs graph.txt" " 1 -> [3, 4, 5]"$'\n'" 2 -> [5, 6]"$'\n'" 3 -> [1, 4, 6]"$'\n'" 4 -> [1, 3]"$'\n'" 5 -> [1, 2, 6]"$'\n'" 6 -> [2, 3, 5]"$'\n'" 7 -> [8, 10]"$'\n'" 8 -> [7, 9]"$'\n'" 9 -> [8, 10]"$'\n'"10 -> [7, 9]"$'\n'"Depth-first search: 1 3 4 6 2 5 7 8 9 10"
rm -rf graph.txt

(cat << ENDOFTEXT
1 4
1 2
4 2
4 3
3 2
5 2
3 5
8 2
8 6
ENDOFTEXT
) > graph.txt
run_test_args "unweighted_d top graph.txt" "1 -> [2, 4]"$'\n'"2 -> []"$'\n'"3 -> [2, 5]"$'\n'"4 -> [2, 3]"$'\n'"5 -> [2]"$'\n'"6 -> []"$'\n'"7 -> []"$'\n'"8 -> [2, 6]"$'\n'"Topological sort: 1 4 3 5 7 8 2 6"
rm -rf graph.txt

(cat << ENDOFTEXT
7 11
7 8
5 11
3 8
3 10
11 2
11 9
11 10
8 9
3 10
ENDOFTEXT
) > graph.txt
run_test_args "unweighted_d top graph.txt" " 1 -> []"$'\n'" 2 -> []"$'\n'" 3 -> [8, 10]"$'\n'" 4 -> []"$'\n'" 5 -> [11]"$'\n'" 6 -> []"$'\n'" 7 -> [8, 11]"$'\n'" 8 -> [9]"$'\n'" 9 -> []"$'\n'"10 -> []"$'\n'"11 -> [2, 9, 10]"$'\n'"Topological sort: 1 3 4 5 6 7 8 11 2 9 10"
rm -rf graph.txt

(cat << ENDOFTEXT
1 2
2 1
ENDOFTEXT
) > graph.txt
run_test_args "unweighted_d top graph.txt" "1 -> [2]"$'\n'"2 -> [1]"$'\n'"Topological sort: impossible"
rm -rf graph.txt

(cat << ENDOFTEXT
1 2 3
1 4 7
2 3 4
2 4 2
3 4 5
3 5 6
4 5 4
ENDOFTEXT
) > graph.txt
run_test_args "weighted shpath graph.txt 1 1" "1 -> [2:3, 4:7]"$'\n'"2 -> [1:3, 3:4, 4:2]"$'\n'"3 -> [2:4, 4:5, 5:6]"$'\n'"4 -> [1:7, 2:2, 3:5, 5:4]"$'\n'"5 -> [3:6, 4:4]"$'\n'"Shortest path: 0 units, [1]"
run_test_args "weighted shpath graph.txt 1 2" "1 -> [2:3, 4:7]"$'\n'"2 -> [1:3, 3:4, 4:2]"$'\n'"3 -> [2:4, 4:5, 5:6]"$'\n'"4 -> [1:7, 2:2, 3:5, 5:4]"$'\n'"5 -> [3:6, 4:4]"$'\n'"Shortest path: 3 units, [1 -> 2]"
run_test_args "weighted shpath graph.txt 2 4" "1 -> [2:3, 4:7]"$'\n'"2 -> [1:3, 3:4, 4:2]"$'\n'"3 -> [2:4, 4:5, 5:6]"$'\n'"4 -> [1:7, 2:2, 3:5, 5:4]"$'\n'"5 -> [3:6, 4:4]"$'\n'"Shortest path: 2 units, [2 -> 4]"
run_test_args "weighted shpath graph.txt 4 1" "1 -> [2:3, 4:7]"$'\n'"2 -> [1:3, 3:4, 4:2]"$'\n'"3 -> [2:4, 4:5, 5:6]"$'\n'"4 -> [1:7, 2:2, 3:5, 5:4]"$'\n'"5 -> [3:6, 4:4]"$'\n'"Shortest path: 5 units, [4 -> 2 -> 1]"
run_test_args "weighted shpath graph.txt 1 5" "1 -> [2:3, 4:7]"$'\n'"2 -> [1:3, 3:4, 4:2]"$'\n'"3 -> [2:4, 4:5, 5:6]"$'\n'"4 -> [1:7, 2:2, 3:5, 5:4]"$'\n'"5 -> [3:6, 4:4]"$'\n'"Shortest path: 9 units, [1 -> 2 -> 4 -> 5]"
run_test_args "weighted shpath graph.txt 5 2" "1 -> [2:3, 4:7]"$'\n'"2 -> [1:3, 3:4, 4:2]"$'\n'"3 -> [2:4, 4:5, 5:6]"$'\n'"4 -> [1:7, 2:2, 3:5, 5:4]"$'\n'"5 -> [3:6, 4:4]"$'\n'"Shortest path: 6 units, [5 -> 4 -> 2]"
rm -rf graph.txt

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
