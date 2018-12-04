/*
 * Name : unique.cpp
 * Author : Mitra Modi
 * Created on: Sep 23, 2018
 * Description : Checks if a given string, when all lowercase, is a string made from all unique letters.
 * Pledge : I pledge my honor that I have abided by the stevens honor system.
 */

#include <cctype>
#include <iostream>
#include <string>

using namespace std;

/*
 * Checks if string is all lowercase by using the islower() with a not, to check for all cases where the letter is not lowercase
 */
bool is_lower(const string &s){
	for (unsigned int i = 0; i < s.length(); i++){ //Iterates through the string
		if (!islower(s[i])){ //
			return false;
		}
	}
	return true;
}
/*
 * Takes a string as an argument, iterates through the string bitshifting the values to a unique position on the variable for res,
 * or returning false if that position is already taken
 */
bool is_unique(const string &s){
	unsigned int res = 0;
	for(unsigned int i = 0; i < s.length(); i++ ){
		int shifter = s[i] - 97;
		if((res & (1 << shifter)) > 0){ //Assesses if the character has repeated
			return false;
		}
		res = res|(1 << shifter);//Increments the position
	}
	return true;
}

int main(int argc, char *argv[]){
	if(argc != 2){
		cout << "Usage: ./unique <string>" << endl; //Case 1: Incorrect number of arguments
	}
	else if(!is_lower(argv[1])){
		cout << "Error: String must contain only lowercase letters." << endl; //Case 2:  Non-lowercase letter
	} else if (is_lower(argv[1])){
		if(is_unique(argv[1])){
			cout << "All letters are unique." << endl; //Case 3: All are unique
		} else {
			cout << "Duplicate letters found." << endl;//Case 4: Duplicates found
		}
	}
	return 0;

}



