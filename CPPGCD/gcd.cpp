/*
 * gcd.cpp
 *
 *  Created on: Aug 31, 2018
 *      Author: Mitra Modi
 *
 *      "I pledge my honor that I have abided by the stevens honor system." - Mitra Modi
 */
#include <iostream>
#include <sstream>

using namespace std;

int gcd_iterative(int m, int n){
	int r;
	while(n != 0){
		r = m % n;
		m = n;
		n = r;
	}
	return abs(m);
}

int gcd_recursive(int m, int n){
	if (n == 0){
		return abs(m);
	} else {
		return gcd_recursive(n, m%n);
	}
}

int main(int argc, char *argv[]) {
	int m, n;
	if (argc != 3) {
		cerr << "Usage: " <<argv[0] << " <integer m> <integer n>" << endl;
		return 1;
	}
	istringstream iss;
	iss.str(argv[1]);
	if (!(iss >> m)) {
		cerr << "Error: The first argument is not a valid integer." << endl;
		return 1;
	}
	iss.clear();
	iss.str(argv[2]);
	if (!(iss >> n)) {
			cerr << "Error: The second argument is not a valid integer." << endl;
			return 1;
	}
	cout << "Iterative: " << "gcd(" << m << ", " << n << ") = " << gcd_iterative(m, n) << endl;
	cout << "Recursive: " << "gcd(" << m << ", " << n << ") = " << gcd_iterative(m, n) << endl;
	return 0;
}
