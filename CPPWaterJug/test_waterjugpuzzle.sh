#!/bin/bash

file=waterjugpuzzle.cpp

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

run_test_args "" "Usage: ./waterjugpuzzle <cap A> <cap B> <cap C> <goal A> <goal B> <goal C>"
run_test_args "1 2 3 4 5 6 7" "Usage: ./waterjugpuzzle <cap A> <cap B> <cap C> <goal A> <goal B> <goal C>"
run_test_args "x 2 3 4 5 6" "Error: Invalid capacity 'x' for jug A."
run_test_args "1 -2 3 4 5 6" "Error: Invalid capacity '-2' for jug B."
run_test_args "1 2 0 4 5 6" "Error: Invalid capacity '0' for jug C."
run_test_args "1 2 3 y 5 6" "Error: Invalid goal 'y' for jug A."
run_test_args "1 2 3 4 -5 6" "Error: Invalid goal '-5' for jug B."
run_test_args "1 2 3 4 5 -1" "Error: Invalid goal '-1' for jug C."
run_test_args "3 5 8 4 0 4" "Error: Goal cannot exceed capacity of jug A."
run_test_args "3 5 8 0 6 2" "Error: Goal cannot exceed capacity of jug B."
run_test_args "3 5 8 0 0 9" "Error: Goal cannot exceed capacity of jug C."
run_test_args "3 5 8 2 1 4" "Error: Total gallons in goal state must be equal to the capacity of jug C."
run_test_args "6 7 10 5 5 0" "No solution."
run_test_args "30 45 50 25 25 0" "No solution."
run_test_args "3 5 8 2 1 5" "No solution."
run_test_args "5 7 10 3 3 4" "No solution."
run_test_args "6 7 10 0 0 10" "Initial state. (0, 0, 10)"
run_test_args "3 5 8 0 5 3" "Initial state. (0, 0, 8)"$'\n'"Pour 5 gallons from C to B. (0, 5, 3)"
run_test_args "3 5 8 0 3 5" "Initial state. (0, 0, 8)"$'\n'"Pour 3 gallons from C to A. (3, 0, 5)"$'\n'"Pour 3 gallons from A to B. (0, 3, 5)"
run_test_args "1 3 4 0 2 2" "Initial state. (0, 0, 4)"$'\n'"Pour 3 gallons from C to B. (0, 3, 1)"$'\n'"Pour 1 gallon from B to A. (1, 2, 1)"$'\n'"Pour 1 gallon from A to C. (0, 2, 2)"
run_test_args "3 5 8 0 2 6" "Initial state. (0, 0, 8)"$'\n'"Pour 5 gallons from C to B. (0, 5, 3)"$'\n'"Pour 3 gallons from B to A. (3, 2, 3)"$'\n'"Pour 3 gallons from A to C. (0, 2, 6)"
run_test_args "3 5 8 0 4 4" "Initial state. (0, 0, 8)"$'\n'"Pour 5 gallons from C to B. (0, 5, 3)"$'\n'"Pour 3 gallons from B to A. (3, 2, 3)"$'\n'"Pour 3 gallons from A to C. (0, 2, 6)"$'\n'"Pour 2 gallons from B to A. (2, 0, 6)"$'\n'"Pour 5 gallons from C to B. (2, 5, 1)"$'\n'"Pour 1 gallon from B to A. (3, 4, 1)"$'\n'"Pour 3 gallons from A to C. (0, 4, 4)"
run_test_args "4 7 10 0 5 5" "Initial state. (0, 0, 10)"$'\n'"Pour 4 gallons from C to A. (4, 0, 6)"$'\n'"Pour 4 gallons from A to B. (0, 4, 6)"$'\n'"Pour 4 gallons from C to A. (4, 4, 2)"$'\n'"Pour 3 gallons from A to B. (1, 7, 2)"$'\n'"Pour 7 gallons from B to C. (1, 0, 9)"$'\n'"Pour 1 gallon from A to B. (0, 1, 9)"$'\n'"Pour 4 gallons from C to A. (4, 1, 5)"$'\n'"Pour 4 gallons from A to B. (0, 5, 5)"
run_test_args "8 17 20 0 10 10" "Initial state. (0, 0, 20)"$'\n'"Pour 17 gallons from C to B. (0, 17, 3)"$'\n'"Pour 8 gallons from B to A. (8, 9, 3)"$'\n'"Pour 8 gallons from A to C. (0, 9, 11)"$'\n'"Pour 8 gallons from B to A. (8, 1, 11)"$'\n'"Pour 8 gallons from A to C. (0, 1, 19)"$'\n'"Pour 1 gallon from B to A. (1, 0, 19)"$'\n'"Pour 17 gallons from C to B. (1, 17, 2)"$'\n'"Pour 7 gallons from B to A. (8, 10, 2)"$'\n'"Pour 8 gallons from A to C. (0, 10, 10)"
run_test_args "4 17 22 2 5 15" "No solution."

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
