/*******************************************************************************
 * Name          : pointers.cpp
 * Author        : Brian S. Borowski
 * Version       : 1.0
 * Date          : May 20, 2015
 * Last modified : September 8, 2016
 * Description   : Fun with pointers
 ******************************************************************************/
#include <iostream>

using namespace std;

void display_array(int array[], const int length) {
    cout << "[";
    for (int i = 0; i < length; ++i) {
        if (i != 0) {
            cout << ", ";
        }
        cout << array[i];
    }
    cout << "]" << endl;
}

void display_array_ptr(int array[], const int length) {
    cout << "[";
    for (int *ptr = array, *end = array + length; ptr < end; ++ptr) {
        if (ptr != array) {
            cout << ", ";
        }
        cout << *ptr;
    }
    cout << "]" << endl;
}

void pass_by_value(int x) {
	cout << x << endl;
    x = 10;
    cout << x << endl;
}

void pass_by_pointer(int *x) {
    *x = 10;
}

void pass_by_reference(int &x) {
	cout << x << endl;
    x = 10;
    cout << x << endl;
}

int main() {
    int x = 5, y = 6, *z = &x;
    cout << z << endl;
    cout << *z << endl;
    cout << "x = " << x << ", " << "y = " << y << endl;
    *z = 7;
    cout << "x = " << x << ", " << "y = " << y << endl;
    z = &y;
    *z = 10;
    cout << "x = " << x << ", " << "y = " << y << endl;
    cout << ++z << endl; // BAD IDEA: We're not sure what z points to now.
    cout << *z << endl;
    z += 30000;          // TERRIBLE IDEA: z points outside the address space
                         // of this process.
    // *z = 20;          // Assigning a new value to the place z points will
                         // cause a segmentation fault.

    int* values = new int[y];
    for (int i = 0; i < y; i++) {
        values[i] = i;
    }
    display_array(values, y);
    display_array_ptr(values, y);
    delete [] values;

    x = 5;
    y = 6;
    cout << "PASS BY VALUE" << endl;
    pass_by_value(x);
    cout << "x = " << x << ", " << "y = " << y << endl;

    x = 5;
    y = 6;
    cout << "PASS BY POINTER" << endl;
    pass_by_pointer(&x);
    cout << "x = " << x << ", " << "y = " << y << endl;

    x = 5;
    y = 6;
    cout << "PASS BY REFERENCE" << endl;
    pass_by_reference(x);
    cout << "x = " << x << ", " << "y = " << y << endl;

    return 0;
}
