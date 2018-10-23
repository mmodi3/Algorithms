/*
 * Name : stairclimber.cpp
 * Author : Mitra Modi
 * Created on: Oct 2, 2018
 * Description : Displays all different ways you can climb n stairs, 1, 2, or 3 steps at a time
 * Pledge : I pledge my honor that I have abided by the stevens honor system.
 */
#include <iostream>
#include <vector>
#include <algorithm>
#include <sstream>
#include <iomanip>

using namespace std;

vector<vector<int>> allways; //Vector to store all vector combinations of ways
vector<int> currway; //Vector that stores the current way

vector<vector<int>> get_ways(int num_stairs) {//Returns vector with all ways to climb "num_stairs" stairs
    if(num_stairs == 0){ //Base case to push the current way you are adding to the
    		allways.push_back(currway);
    }
    if(num_stairs >= 1){ //Case to add 1 to currway
    		currway.push_back(1);
    		get_ways(num_stairs-1);
    		currway.pop_back();
    }
    if(num_stairs >= 2){ //Case to add 2 to currway
    		currway.push_back(2);
    		get_ways(num_stairs-2);
    		currway.pop_back();
    }
    if(num_stairs >= 3){ //Case to add 3 to currway
    		currway.push_back(3);
    		get_ways(num_stairs-3);
    		currway.pop_back();
    }
    return allways; //Returns vector with all ways to climb "num_stairs" stairs
}

void display_ways(const vector<vector<int>> &ways) { //Displays all of the ways as separate lines, enumerated and left-justified to the start of the lists
	int max = ways.size() + 1; //Finds max number in the enumerated number of ways
	int maxwidth = 1; //Checks the width of the max number to align the enumerations
	while(max > 9){
		max = max/10;
		maxwidth++;

	}

    for(unsigned int i = 0; i < ways.size(); i++){ //Loops through all ways
    		for(unsigned int j = 0; j < ways[i].size(); j++){ //Loops through all values in the current vector
    			if(j == 0){ //Checks if it is first value being printed
    				cout << setw(maxwidth) << i + 1<< ". "; //Prints number for the enumerated list, set to the width of the largest number
    				cout << "["; //Prints opening square bracket
    			}
    			if(j < ways[i].size()-1){  //Checks if current value is not the final value
    				cout << ways[i][j] << ", "; //Prints current value followed by a comma
    			}
    			if (j == ways[i].size() - 1){ //checks if current value is the final value
    				cout << ways[i][j] << "]"; //Prints final value followed by a closing square bracket
    			}
    		}
    		cout << endl;
    }
}

int main(int argc, char * const argv[]) {
	int m;
	istringstream iss;

	if(argc != 2 || argv[2]){
		cout << "Usage: ./stairclimber <number of stairs>" << endl; //Checks if invalid argument count
	}

	else {
		iss.str(argv[1]);
		if(atoi(argv[1]) <= 0 || !(iss >> m)){
		cout << "Error: Number of stairs must be a positive integer."; //Checks if invalid argument parameter
		} else {
		vector<vector<int>> res = get_ways(atoi(argv[1]));
		if (m > 1){
			cout << res.size() << " " << "ways to climb " << argv[1] << " stairs." << endl;
		} else {
			cout << res.size() << " " << "way to climb " << argv[1] << " stair." << endl;
		}
		display_ways(res);
		}
	}
}




