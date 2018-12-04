#!/bin/bash

file=quickselect.cpp
MAXTIME="2.0"

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

timeout() {
    time=$1

    # start the command in a subshell to avoid problem with pipes
    # (spawn accepts one command)
    cmd="/bin/bash -c \"$2\""

    expect -c "set echo \"-noecho\"; set timeout $time; spawn -noecho $cmd; expect timeout { exit 1 } eof { exit 0 }"    

    if [ $? -eq 1 ]; then
        return 0
    fi
    return 1
}

run_test_args() {
    (( ++total ))
    echo -n "Running test $total..."
    expected=$3
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
(cat << ENDOFTEXT
$2
ENDOFTEXT
) > input.txt
    if timeout $MAXTIME "cat input.txt | $command $1 2>&1 | tr -d '\r' > tmp.txt"; then
        echo "failure [timed out after $MAXTIME seconds]"
    else
        received=$(cat tmp.txt)
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
            echo "success [$elapsed seconds]"
            (( ++num_right ))
        fi
    fi
    rm -f tmp.txt input.txt
}

run_test_args "lots of args" "" "Usage: ./quickselect <k>"
run_test_args "w" "" "Error: Invalid value 'w' for k."
run_test_args "0" "" "Error: Invalid value '0' for k."
run_test_args "-8" "" "Error: Invalid value '-8' for k."
run_test_args "3" "x 1 2 3" "Enter sequence of integers, each followed by a space: Error: Non-integer value 'x' received at index 0."
run_test_args "3" "1 2 x 3" "Enter sequence of integers, each followed by a space: Error: Non-integer value 'x' received at index 2."
run_test_args "4" "" "Enter sequence of integers, each followed by a space: Error: Sequence of integers not received."
run_test_args "4" "  " "Enter sequence of integers, each followed by a space: Error: Sequence of integers not received."
run_test_args "4" "1 2" "Enter sequence of integers, each followed by a space: Error: Cannot find smallest element 4 with only 2 values."
run_test_args "5" "1" "Enter sequence of integers, each followed by a space: Error: Cannot find smallest element 5 with only 1 value."

run_test_args "1" "1" "Enter sequence of integers, each followed by a space: Smallest element 1: 1"
run_test_args "1" "1000" "Enter sequence of integers, each followed by a space: Smallest element 1: 1000"
run_test_args "2" "1 2" "Enter sequence of integers, each followed by a space: Smallest element 2: 2"
run_test_args "2" "23 16" "Enter sequence of integers, each followed by a space: Smallest element 2: 23"
run_test_args "5" "1 3 5 2 4" "Enter sequence of integers, each followed by a space: Smallest element 5: 5"
run_test_args "3" "10 12 16 14 11" "Enter sequence of integers, each followed by a space: Smallest element 3: 12"
run_test_args "3" "-78 -89 -12 -9 -671 -78" "Enter sequence of integers, each followed by a space: Smallest element 3: -78"
run_test_args "1" "3 6 2 4 768 1 4 567 123 65 12 345 12 -100" "Enter sequence of integers, each followed by a space: Smallest element 1: -100"
run_test_args "4" "3 6 2 4 768 1 4 567 123 65 12 345 12 -100" "Enter sequence of integers, each followed by a space: Smallest element 4: 3"
run_test_args "6" "3 6 2 4 768 1 4 567 123 65 12 345 12 -100" "Enter sequence of integers, each followed by a space: Smallest element 6: 4"
run_test_args "9" "3 6 2 4 768 1 4 567 123 65 12 345 12 -100" "Enter sequence of integers, each followed by a space: Smallest element 9: 12"
run_test_args "10" "5 5 5 5 5 5 5 5 5 5 5 5" "Enter sequence of integers, each followed by a space: Smallest element 10: 5"
run_test_args "12" "-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1" "Enter sequence of integers, each followed by a space: Smallest element 12: -1"
run_test_args "10000" "$(echo {1..100000})" "Enter sequence of integers, each followed by a space: Smallest element 10000: 10000"
run_test_args "8765" "$(echo {100000..1})" "Enter sequence of integers, each followed by a space: Smallest element 8765: 8765"

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
