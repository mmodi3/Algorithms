/*******************************************************************************
 * Name        : inversioncounter.cpp
 * Author      : Mitra Modi
 * Version     : 1.0
 * Date        : 11/3/18
 * Description : Counts the number of inversions in an array.
 * Pledge      : I pledge my honor that I have abided by the stevens honor system - Mitra Modi
 ******************************************************************************/
#include <iostream>
#include <algorithm>
#include <sstream>
#include <vector>
#include <cstdio>
#include <cctype>
#include <cstring>

using namespace std;

// Function prototype.
static long mergesort(int array[], int scratch[], int low, int high);

/**
 * Counts the number of inversions in an array in theta(n^2) time.
 */
long count_inversions_slow(int array[], int length) {
	long count = 0;
    for (int i = 0; i < length - 1; i++){
    		int currval = array[i];
    		for (int j = i; j < length; j++){
    			if (array[j] < currval){
    				count++;
    			}
    		}
    }
    return count;
}

/**
 * Counts the number of inversions in an array in theta(n lg n) time.
 */
long count_inversions_fast(int array[], int length) {
	int* scratch = new int[length];
	long res = mergesort(array, scratch, 0, length-1);
	delete [] scratch;
	return res;
}

static long mergesort(int array[], int scratch[], int low, int high) {
	long res = 0;
    if(low < high){
    		int mid = (low + (high - low)/2);
    		res += mergesort(array, scratch, low, mid);
    		res += mergesort(array, scratch, mid+1, high);
    		int L = low;
    		int H = mid+1;
    		for(int k = low; k < high + 1; k++){
    			if(L <= mid && (H > high || array[L] <= array[H])){
    				scratch[k] = array[L];
    				L++;
    			} else {
    				scratch[k] = array[H];
    				res += (mid - L + 1);
    				H++;
    			}
    		}
    		for(int k = low; k < high+1; k++){
    			array[k] = scratch[k];
    		}
    }
    return res;
}

int main(int argc, char *argv[]) {
    // TODO: parse command-line argument
	if (argc == 2 && strcmp(argv[1], "slow")){
		cerr << "Error: Unrecognized option '" << argv[1] << "'." << endl;
	}
	else if (argc > 2){
		cerr << "Usage: ./inversioncounter [slow]" << endl;
	}
	else {
    cout << "Enter sequence of integers, each followed by a space: " << flush;

    istringstream iss;
    int value, index = 0;
    vector<int> values;
    string str;
    str.reserve(11);
    char c;
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
            } else {
				cerr << "Error: Sequence of integers not received." << endl;
				return 1;
            }
            if (eoln) {
                break;
            }
            str.clear();
        } else {
            str += c;
        }
    }
    int length = values.size();
    int* res = new int[length]; //Sets vector of values into an array so it matches the function's parameters
    for(int i = 0; i < length; ++i){
    		res[i] = values[i];
    }
    cout << "Number of inversions: " << count_inversions_fast(res, length) << endl;
    delete [] res;
    return 0;
	}
}
