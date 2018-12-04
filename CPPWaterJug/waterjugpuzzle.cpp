/*
 * Name : stairclimber.cpp
 * Author : Mitra Modi, Mathew Seedhom
 * Created on: Oct 17, 2018
 * Description : Displays shortest path to get to
 * Pledge : I pledge my honor that I have abided by the Stevens honor system.
 */

#include <iostream>
#include <sstream>
#include <vector>
#include <queue>

using namespace std;
// Struct to represent state of water in the jugs.
struct State {
    int a, b, c;
    vector<string> directions;

    State(int _a, int _b, int _c) : a(_a), b(_b), c(_c) { }
    
    // String representation of state in tuple form.
    string to_string() {
        ostringstream oss;
        oss << "(" << a << ", " << b << ", " << c << ")";
        return oss.str();
    }

    //Used as to compare two states for equivalence
    bool equals(State compare){
    		return a == compare.a && b == compare.b && c == compare.c;
    }

    //Used to print the steps followed to arrive at solution
    void print_steps(){
    		for(unsigned int i = 0; i < directions.size()-1; i++){
    			cout << directions[i] << endl;
    		}
    		cout << directions[directions.size()-1];
    }
};

//Returns gallon in singular or plural form depending on the number of gallons poured
string gallon(int n){
	if(n>1){
		return " gallons ";
	} else {
		return " gallon ";
	}
}

//Pours gallons from Jug A to Jug B
State PourAB(State current, int currpour, int currrec, int caprec){
	if(caprec  >= currpour + currrec){
		vector<string> newdirections = current.directions;
		State res =  State(0, currpour + currrec, current.c);
		res.directions = current.directions;
		res.directions.push_back("Pour " + to_string(currpour) +  gallon(currpour) +  "from A to B. " + res.to_string());
		return res;
	} else {
		int afterpour = currpour - (caprec-currrec);
		State res = State(afterpour, caprec, current.c);
		res.directions = current.directions;
		res.directions.push_back("Pour " + to_string(currpour - afterpour) + gallon(currpour - afterpour) +  "from A to B. " + res.to_string());
		return res;
		}
	}

//Pours gallons from Jug A to Jug C
State PourAC(State current, int currpour, int currrec, int caprec){
	if(caprec  >= currpour + currrec){
		State res = State(0, current.b, currpour + currrec);
		res.directions = current.directions;
		res.directions.push_back("Pour " + to_string(currpour) + gallon(currpour) +  "from A to C. " + res.to_string());
		return res;
	} else {
		int afterpour = currpour - (caprec-currrec);
		State res = State(afterpour, current.b, caprec);
		res.directions = current.directions;
		res.directions.push_back("Pour " + to_string(currpour - afterpour) + gallon(currpour - afterpour) +  "from A to C. " + res.to_string());
		return res;
		}
	}

//Pours gallons from Jug B to Jug A
State PourBA(State current, int currpour, int currrec, int caprec){
	if(caprec  >= currpour + currrec){
		State res =  State(currpour + currrec, 0, current.c);
		res.directions = current.directions;
		res.directions.push_back("Pour " + to_string(currpour) + gallon(currpour) +  "from B to A. " + res.to_string());
		return res;
	} else {
		int afterpour = currpour - (caprec-currrec);
		State res = State(caprec, afterpour, current.c);
		res.directions = current.directions;
		res.directions.push_back("Pour " + to_string(currpour - afterpour) + gallon(currpour - afterpour) +  "from B to A. " + res.to_string());
		return res;
		}
	}

//Pours gallons from Jug B to Jug C
State PourBC(State current, int currpour, int currrec, int caprec){
	if(caprec  >= currpour + currrec){
		State res =  State(current.a, 0, currpour + currrec);
		res.directions = current.directions;
		res.directions.push_back("Pour " + to_string(currpour) + gallon(currpour) +  "from B to C. " + res.to_string());
		return res;
	} else {
		int afterpour = currpour - (caprec-currrec);
		State res =  State(current.a, afterpour, caprec);
		res.directions =  current.directions;
		res.directions.push_back("Pour " + to_string(currpour - afterpour) + gallon(currpour - afterpour) +  "from B to C. " + res.to_string());
		return res;
		}
	}

//Pours gallons from Jug C to Jug A
State PourCA(State current, int currpour, int currrec, int caprec){
	if(caprec  >= currpour + currrec){
		State res =  State(currpour + currrec, current.b, 0);
		res.directions = current.directions;
		res.directions.push_back("Pour " + to_string(currpour) + gallon(currpour) +  "from C to A. " + res.to_string());
		return res;
	} else {
		int afterpour = currpour - (caprec-currrec);
		State res = State(caprec, current.b, afterpour);
		res.directions = current.directions;
		res.directions.push_back("Pour " + to_string(currpour - afterpour) + gallon(currpour - afterpour) +  "from C to A. " + res.to_string());
		return res;
		}
	}

//Pours gallons from Jug C to Jug B
State PourCB(State current, int currpour, int currrec, int caprec){
	if(caprec  >= currpour + currrec){
		State res = State(current.a, currpour + currrec, 0);
		res.directions = current.directions;
		res.directions.push_back("Pour " + to_string(currpour) + gallon(currpour) +  "from C to B. " + res.to_string());
		return res;
	} else {
		int afterpour = currpour - (caprec-currrec);
		State res =  State(current.a, caprec, afterpour);
		res.directions = current.directions;
		res.directions.push_back("Pour " + to_string(currpour - afterpour) + gallon(currpour - afterpour) +  "from C to B. " + res.to_string());
		return res;
		}
	}

//Finds shortest way to solve using breadth first search as a means of getting to the desired configuration of Jugs with
//the shortest amount of steps. Returns "No solution." if there is no possible solution
void ways_to_solve(State initial, State capacity, State goal){
	queue<State> states;
	bool** visited = new bool*[capacity.a + 1]; //2-D matrix to check visited
	bool solutionfound = false; //Bool value for whether or not a solution was printed
	for(int i = 0; i < capacity.a + 1; i++){ //Create and set all nested array's values to false
		visited[i] = new bool[capacity.b+1];
		for(int j = 0; j < capacity.b + 1; j++){
			visited[i][j] = false;
		}
	}
	State first = initial;
	first.directions.push_back("Initial state. " + first.to_string());
	states.push(first);
	while(!states.empty()){ //Iterates till all paths are checked
		State current = states.front();
		states.pop();
		if(current.equals(goal)){
			current.print_steps();
			solutionfound = true;
			for(int i = 0; i<= capacity.a; i++) {
					
                [] visited[i];
			}
			delete [] visited;
			break;
		}
		if(visited[current.a][current.b] == true){
			continue;
		} else {
			visited[current.a][current.b] = true;
		}
		if(current.a != capacity.a && current.c != 0){ //Pours from C to A if possible
			states.push(PourCA(current, current.c, current.a, capacity.a));
		}
		if(current.a != capacity.a && current.b != 0){ //Pours from B to A if possible
			states.push(PourBA(current, current.b, current.a, capacity.a));
		}
		if(current.b != capacity.b && current.c != 0){ //Pours from C to B if possible
			states.push(PourCB(current, current.c, current.b, capacity.b));
		}
		if(current.b != capacity.b && current.a != 0){ //Pours from A to B if possible
			states.push(PourAB(current, current.a, current.b, capacity.b));
		}
		if(current.c != capacity.c && current.b != 0){ //Pours from B to C if possible
			states.push(PourBC(current, current.b, current.c, capacity.c));
		}
		if(current.c != capacity.c && current.a != 0){ //Pours from A to C if possible
			states.push(PourAC(current, current.a, current.c, capacity.c));
		}
	}
	if(!solutionfound){ //Checks if no solution found
		cout << "No solution." << endl;
	}
}

int main(int argc, char * argv[]) {
	string letter[6] = {"A", "B", "C", "A", "B", "C"};

	if (argc != 7){
		cerr << "Usage: ./waterjugpuzzle <cap A> <cap B> <cap C> <goal A> <goal B> <goal C>";
		return 1;
	}

	istringstream iss;
	int check;
	for (int i = 1; i < 4; i++){
		iss.str(argv[i]);
		if (!(iss >> check) || atoi(argv[i])<0){ //Checks if invalid capacity
			cerr << "Error: Invalid capacity '" << argv[i] << "' for jug " << letter[i-1]<<".";
			return 1;
		}
		if (i == 3 && atoi(argv[i])==0){ //Checks if Jug C capacity is 0
			cerr << "Error: Invalid capacity '" << argv[i] << "' for jug " << letter[i-1]<<".";
				return 1;
		}
		iss.clear();
	}
	for (int i = 4; i < 7; i++){
			iss.str(argv[i]);
			if (!(iss >> check) || atoi(argv[i])<0){ //Checks if invalid goal
				cerr << "Error: Invalid goal '" << argv[i] << "' for jug " << letter[i-1]<<".";
				return 1;
			}
			if (i == 3 && atoi(argv[i])==0){ //Checks if Jug C goal is 0
				cerr << "Error: Invalid capacity '" << argv[i] << "' for jug " << letter[i-1]<<".";
				return 1;
			}
			iss.clear();
	}
	//Set values for capacity and goal, just for easier reading of code
	int capa = atoi(argv[1]);
	int capb = atoi(argv[2]);
	int capc = atoi(argv[3]);
	int goala = atoi(argv[4]);
	int goalb = atoi(argv[5]);
	int goalc = atoi(argv[6]);
	//Character to track which goal exceeds
	char eletter = 'X';
	if(goala > capa){
		eletter = 'A';
	}
	else if(goalb > capb){
		eletter = 'B';
	}
	else if(goalc > capc){
		eletter = 'C';
	}
	if(eletter == 'A' || eletter == 'B' || eletter == 'C'){ //Checks for first goal that exceeded the capacity, if any exceeded
		cerr << "Error: Goal cannot exceed capacity of jug " << eletter << ".";
		return 1;
	}
	if (capc != goala + goalb + goalc){ //Checks if total gallons in goal is equal to the capacity of Jug C
		cerr << "Error: Total gallons in goal state must be equal to the capacity of jug C.";
		return 1;
	}
	State cap = State(capa, capb, capc);
	State goal = State(goala, goalb, goalc);
	State start = State(0, 0, capc);
	ways_to_solve(start, cap, goal);
	return 0;
	}
