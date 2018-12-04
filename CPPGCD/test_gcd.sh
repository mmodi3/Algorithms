#!/bin/bash

file=gcd.cpp

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

run_test_args "" "Usage: ./gcd <integer m> <integer n>"
run_test_args "42 16 8" "Usage: ./gcd <integer m> <integer n>"
run_test_args "cat 16" "Error: The first argument is not a valid integer."
run_test_args "42 dog" "Error: The second argument is not a valid integer."
run_test_args "0 0" "Iterative: gcd(0, 0) = 0"$'\n'"Recursive: gcd(0, 0) = 0"
run_test_args "1 0" "Iterative: gcd(1, 0) = 1"$'\n'"Recursive: gcd(1, 0) = 1"
run_test_args "2 4" "Iterative: gcd(2, 4) = 2"$'\n'"Recursive: gcd(2, 4) = 2"
run_test_args "42 16" "Iterative: gcd(42, 16) = 2"$'\n'"Recursive: gcd(42, 16) = 2"
run_test_args "21 42" "Iterative: gcd(21, 42) = 21"$'\n'"Recursive: gcd(21, 42) = 21"
run_test_args "1000 48" "Iterative: gcd(1000, 48) = 8"$'\n'"Recursive: gcd(1000, 48) = 8"
run_test_args "48 -20" "Iterative: gcd(48, -20) = 4"$'\n'"Recursive: gcd(48, -20) = 4"
run_test_args "-8 80" "Iterative: gcd(-8, 80) = 8"$'\n'"Recursive: gcd(-8, 80) = 8"

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
