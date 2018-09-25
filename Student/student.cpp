/*******************************************************************************
 * Name          : studentclass.cpp
 * Author        : Mitra Modi
 * Date          : 7/9/18
 * I pledge my honor that I have abided by the stevens honor system - Mitra Modi
 ******************************************************************************/
#include <iostream>
#include <iomanip>
#include <vector>

using namespace std;

class Student {

private:
	string first_;
	string last_;
	float gpa_;
	int id_;

public:
    // Constructor that uses an initializer list to with parameters FIRST LAST GPA and ID
    Student(string first, string last, float gpa, int id) : first_{first}, last_{last}, gpa_{gpa}, id_{id} { }

    string full_name() const{
    	//Returns name of student with format FIRST LAST
    		string fullname = first_ + " " + last_;
    		return fullname;
    }

    int id() const{
    	//Returns ID of student
    		return id_;
    }

    float gpa() const{
    	//Returns GPA of student
    		return gpa_;
    }

    void print_info() const{
    	//Prints the information of the student with the format FIRST LAST GPA ID
    	cout  << first_  << " " << last_ << ", GPA: " << fixed
    	<< setprecision(2) << gpa_ << ", ID: " << id_ << endl;
    }

};

/**
* Takes a vector of Student objects, and returns a new vector
* with all Students whose GPA is < 1.0.
*/
vector<Student> find_failing_students(const vector<Student> &students) {
    vector<Student> failing_students;
    // Iterates through the students vector, appending each student whose gpa is
    // less than 1.0 to the failing_students vector.
    for (const auto &it : students) {
    		if (it.gpa() < 1.0){
    			failing_students.push_back(it);
    		}
    }
    return failing_students;
}

void print_students(const vector<Student> &students) {
// Iterates through the students vector, calling print_info() for each student.
	for (auto it = students.cbegin(); it != students.cend(); ++it){
		it->print_info();
	}
}

/**
* Allows the user to enter information for multiple students, then
* find those students whose GPA is below 1.0 and prints them to the
* screen.
*/
int main() {
    string first_name, last_name;
    float gpa;
    int id;
    char repeat;
    vector<Student> students;
    do {
        cout << "Enter student's first name: ";
        cin >> first_name;
        cout << "Enter student's last name: ";
        cin >> last_name;
        gpa = -1;
        while (gpa < 0 || gpa > 4) {
            cout << "Enter student's GPA (0.0-4.0): ";
            cin >> gpa;
        }
        cout << "Enter student's ID: ";
        cin >> id;
        students.push_back(Student(first_name, last_name, gpa, id));
        cout << "Add another student to database (Y/N)? ";
        cin >> repeat;
    } while (repeat == 'Y' || repeat == 'y');
    cout << endl << "All students:" << endl;
    print_students(students);
    cout << endl << "Failing students:";
    if (find_failing_students(students).empty()){
    	cout << " None";
    } else {
    	cout << endl;
    	print_students(find_failing_students(students));
    }
    // Prints a space and the word 'None' on the same line if no students are
    // failing.
    // Otherwise, prints each failing student on a separate line.
    return 0;
}
