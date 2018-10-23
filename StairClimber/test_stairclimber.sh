#!/bin/bash

file=stairclimber.cpp

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

run_test_args "" "Usage: ./stairclimber <number of stairs>"
run_test_args "123 345" "Usage: ./stairclimber <number of stairs>"
run_test_args "hello" "Error: Number of stairs must be a positive integer."
run_test_args "-23" "Error: Number of stairs must be a positive integer."
run_test_args "1" "1 way to climb 1 stair."$'\n'"1. [1]"
run_test_args "2" "2 ways to climb 2 stairs."$'\n'"1. [1, 1]"$'\n'"2. [2]"
run_test_args "3" "4 ways to climb 3 stairs."$'\n'"1. [1, 1, 1]"$'\n'"2. [1, 2]"$'\n'"3. [2, 1]"$'\n'"4. [3]"
run_test_args "4" "7 ways to climb 4 stairs."$'\n'"1. [1, 1, 1, 1]"$'\n'"2. [1, 1, 2]"$'\n'"3. [1, 2, 1]"$'\n'"4. [1, 3]"$'\n'"5. [2, 1, 1]"$'\n'"6. [2, 2]"$'\n'"7. [3, 1]"
run_test_args "5" "13 ways to climb 5 stairs."$'\n'" 1. [1, 1, 1, 1, 1]"$'\n'" 2. [1, 1, 1, 2]"$'\n'" 3. [1, 1, 2, 1]"$'\n'" 4. [1, 1, 3]"$'\n'" 5. [1, 2, 1, 1]"$'\n'" 6. [1, 2, 2]"$'\n'" 7. [1, 3, 1]"$'\n'" 8. [2, 1, 1, 1]"$'\n'" 9. [2, 1, 2]"$'\n'"10. [2, 2, 1]"$'\n'"11. [2, 3]"$'\n'"12. [3, 1, 1]"$'\n'"13. [3, 2]"
run_test_args "6" "24 ways to climb 6 stairs."$'\n'" 1. [1, 1, 1, 1, 1, 1]"$'\n'" 2. [1, 1, 1, 1, 2]"$'\n'" 3. [1, 1, 1, 2, 1]"$'\n'" 4. [1, 1, 1, 3]"$'\n'" 5. [1, 1, 2, 1, 1]"$'\n'" 6. [1, 1, 2, 2]"$'\n'" 7. [1, 1, 3, 1]"$'\n'" 8. [1, 2, 1, 1, 1]"$'\n'" 9. [1, 2, 1, 2]"$'\n'"10. [1, 2, 2, 1]"$'\n'"11. [1, 2, 3]"$'\n'"12. [1, 3, 1, 1]"$'\n'"13. [1, 3, 2]"$'\n'"14. [2, 1, 1, 1, 1]"$'\n'"15. [2, 1, 1, 2]"$'\n'"16. [2, 1, 2, 1]"$'\n'"17. [2, 1, 3]"$'\n'"18. [2, 2, 1, 1]"$'\n'"19. [2, 2, 2]"$'\n'"20. [2, 3, 1]"$'\n'"21. [3, 1, 1, 1]"$'\n'"22. [3, 1, 2]"$'\n'"23. [3, 2, 1]"$'\n'"24. [3, 3]"

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
