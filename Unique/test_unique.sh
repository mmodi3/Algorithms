#!/bin/bash

file=unique.cpp

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

run_test_args "" "Usage: ./unique <string>"
run_test_args "a b" "Usage: ./unique <string>"
run_test_args "a0b" "Error: String must contain only lowercase letters."
run_test_args "ABC" "Error: String must contain only lowercase letters."
run_test_args "a" "All letters are unique."
run_test_args "aa" "Duplicate letters found."
run_test_args "aba" "Duplicate letters found."
run_test_args "abc" "All letters are unique."
run_test_args "abcdefghijklmnopqrstuvwxyz" "All letters are unique."
run_test_args "zabcdefghijklmnopqrstuvwxy" "All letters are unique."
run_test_args "abcdefghijklmnopqrstuvwxyza" "Duplicate letters found."
run_test_args "zabcdefghijklmnopqrstuvwxyz" "Duplicate letters found."
run_test_args "abcabc" "Duplicate letters found."
run_test_args "funstuph" "Duplicate letters found."
run_test_args "powerful" "All letters are unique."

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
