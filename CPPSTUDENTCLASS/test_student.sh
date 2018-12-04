#!/bin/bash

file=student.cpp

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

run_test() {
    (( ++total ))
    echo -n "Running test $total..."
    expected=$2
    received=$( echo -e $1 | $command 2>&1 | tr -d '\r' )
    if [ "$expected" = "$received" ]; then
        echo "success"
        (( ++num_right ))
    else
        echo -e "failure\n\nExpected$line\n$expected\nReceived$line\n$received\n"
    fi
}

run_test "John\nDoe\n3.0\n12345\nn" "Enter student's first name: Enter student's last name: Enter student's GPA (0.0-4.0): Enter student's ID: Add another student to database (Y/N)? "$'\n'"All students:"$'\n'"John Doe, GPA: 3.00, ID: 12345"$'\n'$'\n'"Failing students: None"
run_test "John\nGrimes\n0.88\n23456\nn" "Enter student's first name: Enter student's last name: Enter student's GPA (0.0-4.0): Enter student's ID: Add another student to database (Y/N)? "$'\n'"All students:"$'\n'"John Grimes, GPA: 0.88, ID: 23456"$'\n'$'\n'"Failing students:"$'\n'"John Grimes, GPA: 0.88, ID: 23456"
run_test "John\nDoe\n3.0\n12345\ny\nJohn\nGrimes\n0.88\n23456\nn" "Enter student's first name: Enter student's last name: Enter student's GPA (0.0-4.0): Enter student's ID: Add another student to database (Y/N)? Enter student's first name: Enter student's last name: Enter student's GPA (0.0-4.0): Enter student's ID: Add another student to database (Y/N)? "$'\n'"All students:"$'\n'"John Doe, GPA: 3.00, ID: 12345"$'\n'"John Grimes, GPA: 0.88, ID: 23456"$'\n'$'\n'"Failing students:"$'\n'"John Grimes, GPA: 0.88, ID: 23456"
run_test "John\nGrimes\n0.88\n23456\nyJohn\nDoe\n1.0\n12345\nn" "Enter student's first name: Enter student's last name: Enter student's GPA (0.0-4.0): Enter student's ID: Add another student to database (Y/N)? Enter student's first name: Enter student's last name: Enter student's GPA (0.0-4.0): Enter student's ID: Add another student to database (Y/N)? "$'\n'"All students:"$'\n'"John Grimes, GPA: 0.88, ID: 23456"$'\n'"John Doe, GPA: 1.00, ID: 12345"$'\n'$'\n'"Failing students:"$'\n'"John Grimes, GPA: 0.88, ID: 23456"
run_test "John\nGrimes\n0.88\n23456\nyJohn\nDoe\n0.9\n12345\nn" "Enter student's first name: Enter student's last name: Enter student's GPA (0.0-4.0): Enter student's ID: Add another student to database (Y/N)? Enter student's first name: Enter student's last name: Enter student's GPA (0.0-4.0): Enter student's ID: Add another student to database (Y/N)? "$'\n'"All students:"$'\n'"John Grimes, GPA: 0.88, ID: 23456"$'\n'"John Doe, GPA: 0.90, ID: 12345"$'\n'$'\n'"Failing students:"$'\n'"John Grimes, GPA: 0.88, ID: 23456"$'\n'"John Doe, GPA: 0.90, ID: 12345"

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
