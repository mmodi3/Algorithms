/*******************************************************************************
 * Name          : mypoint.cpp
 * Author        : Brian S. Borowski
 * Version       : 1.0
 * Date          : January 9, 2016
 * Last modified : September 7, 2017
 * Description   : Class that represents a point in 3D space.
 ******************************************************************************/
#include <iostream>
#include <iomanip>
#include <vector>

using namespace std;

class MyPoint {

public:
    // Constructor that uses an initializer list.
    MyPoint(int x, int y, float z) : x_{x}, y_{y}, z_{z} { }

    //Use x_ just cause google wants you to, in order to make it easier to identify member variables
    //By the time the construction completes, all member variables must be identified
    // Methods that do not modify member variables should be declared const.
    void print_coords() const {
        cout << "(x, y, z) = (" << x_ << ", " << y_ << ", " << fixed
             << setprecision(2) << z_ << ")" << endl;
    }

    // Mutator. Same as setter
    void set_x(int x) {
        x_ = x;
    }

    // Accessor. Same as getter
    int get_x() const {
        return x_;
    }

private:
    // Member variables (fields). Use the trailing _ for these variables.
    int x_, y_;
    float z_;

};

void display_points(const vector<MyPoint> &points) {
    for (auto it = points.cbegin(); it != points.cend(); ++it) {
        it->print_coords();
    }
}
int mystery1(int a, int b) {
    int c = a - b,
        d = (c >> 7) & 1,
        mystery = a - c * d;
    return mystery;
}
int main() {
    int x, y;

    MyPoint point1(5, 7, 1.9823412);
    MyPoint point2(1, 2, 3);
    MyPoint point3(4, 5, 6);

    vector<MyPoint> points;
    points.push_back(point1);
    points.push_back(point2);
    points.push_back(point3);

    vector<MyPoint> points_above_two;
    for (const auto &point : points) {
        if (point.get_x() > 2) {
            points_above_two.push_back(point);
        }
    }

    display_points(points_above_two);

    // Practice using standard in (STDIN).
    cout << "Input x: ";
    cin >> x;

    cout << "Input y: ";
    cin >> y;

    MyPoint some_point(x, y, 7);
    some_point.print_coords();

    MyPoint *heap_point = new MyPoint(2,3,4);
    heap_point->print_coords();
    delete heap_point;



    return 0;
}
