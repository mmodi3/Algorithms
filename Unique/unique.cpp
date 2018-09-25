/*
 * Name : unique.cpp
 * Author : Mitra Modi
 * Created on: Sep 23, 2018
 * Description : 
 * Pledge : I pledge my honor that I have abided by the stevens honor system.
 */

#include <cctype>
#include <iostream>
#include <string>

using namespace std;

bool is_lower(const string &s){
	for (unsigned int i = 0; i < s.length(); i++){ //Iterates through the string
		if (!islower(s[i])){ //
			return false;
		}
	}
	return true;
}

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
		cout << "Usage: ./unique <string>" << endl;
	}
	else if(!is_lower(argv[1])){
		cout << "Error: String must contain only lowercase letters." << endl;
	} else if (is_lower(argv[1])){
		if(is_unique(argv[1])){
			cout << "All letters are unique." << endl;
		} else {
			cout << "Duplicate letters found." << endl;
		}
	}
	return 0;

}



