/*
 * Name : quickselect.cpp
 * Author : Mitra Modi
 * Created on: Oct 26, 2018
 * Description : 
 * Pledge : I pledge my honor that I have abided by the stevens honor system.
 */
#include <iostream>
#include <sstream>
#include <algorithm>
#include <vector>

using namespace std;

void swap(int array[], int index1, int index2){ //Defines a function to swap to array elements
	int temp = array[index1];
	array[index1] = array[index2];
	array[index2] = temp;
}

size_t lomuto_partition(int array[], size_t left, size_t right) { //Returns the correct index of the first element of the array, puts it in it's correct place
	int p = array[left]; //Pivot = value of the first element of the array
	size_t s = 0; //Set s to 0, used to do the array partitions

	for(size_t i = left + 1; i <= right; i++){ //Iterate through partitioned array, not moving the values larger than p, but move smaller ones to the beginning
		if(p > array[i]){
			s++;
			swap(array, i, s + left);
		}
	}
	swap(array, s + left, left); //Swap last value smaller than p with p, to set p in place
	return s;
}

int quick_select(int array[], size_t left, size_t right, size_t k) {
	size_t s = lomuto_partition(array, left, right); //Changes array for first value in array to be in the right place
	if (s == k-1){ //If the index of correctly set value is k-1, return because it is the correct value
		return array[s + left]; //Adds left due to the decrement of k when left is changed
	}else if (s <= k - 1){
		return quick_select(array, s + left + 1, right, k-1-s);
	}else{
		return quick_select(array, left, s + left - 1, k);
	}
}
int quick_select(int array[], const size_t length, size_t k) {
    return quick_select(array, 0, length, k);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        cerr << "Usage: " << argv[0] << " <k>" << endl;
        return 1;
    }

    int k;
    istringstream iss;
    iss.str(argv[1]);
    if ( !(iss >> k) || k <= 0 ) {
        cerr << "Error: Invalid value '" << argv[1] << "' for k." << endl;
        return 1;
    }

    cout << "Enter sequence of integers, each followed by a space: " << flush;
    int value, index = 0;
    vector<int> values;
    string str;
    str.reserve(11);
    char c;
    iss.clear();
    while (true) {
        c = getchar();
        const bool eoln = c == '\r' || c == '\n';
        if (isspace(c) || eoln) {
            if (str.length() > 0) {
                iss.str(str);
                if (iss >> value) {
                    values.push_back(value);
                } else {
                    cerr << "Error: Non-integer value '" << str
                         << "' received at index " << index << "." << endl;
                    return 1;
                }
                iss.clear();
                ++index;
            }
            if (eoln) {
                break;
            }
            str.clear();
        } else {
            str += c;
        }
    }
    int num_values = values.size();
    if (num_values == 0) {
        cerr << "Error: Sequence of integers not received." << endl;
        return 1;
    }
    if (k > num_values && num_values == 1){
    		cerr << "Error: Cannot find smallest element " << k << " with only 1 value."  << endl; //Checks if k is larger than total number of values, and prints value because there is only one value
    } else if (k > num_values){
    		cerr << "Error: Cannot find smallest element " << k << " with only " << num_values << " values."  << endl; //Checks if k is larger than total number of values, and prints 'k' values because there are multiple values
    } else {
    int* array = new int[num_values]; //Sets vector of values into an array so it matches the function's parameters
    for(int i = 0; i < num_values; ++i){
    		array[i] = values[i];
    }
    cout << "Smallest element " <<  k << ": " << quick_select(array, num_values - 1, k); //Prints value of the kth smallest value
    delete [] array; //Deletes array that is allocated on the heap
    return 0;
    }
}




