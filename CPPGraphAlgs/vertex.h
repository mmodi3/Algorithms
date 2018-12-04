/*******************************************************************************
 * Name          : vertex.h
 * Author        : Brian S. Borowski
 * Version       : 1.1
 * Date          : November 17, 2014
 * Last modified : October 16, 2017
 * Description   : Struct for a vertex.
 ******************************************************************************/
#ifndef VERTEX_H_
#define VERTEX_H_

#include "types.h"
#include <cstdlib>
#include <sstream>
#include <string>

struct Vertex {
    vertex_id id, predecessor_id;
    uint_t distance;

    explicit Vertex() : id{0}, predecessor_id{0}, distance{0} { }

    explicit Vertex(uint_t id) :
        id{id}, predecessor_id{0}, distance{0} { }

    explicit Vertex(uint_t id, uint_t predecessor_id, uint_t distance) :
        id{id}, predecessor_id{predecessor_id}, distance{distance} { }

    std::string to_string() const {
        std::ostringstream oss;
        oss << "[" << id << ", " << distance;
        if (predecessor_id == 0) {
            oss << ", NULL]";
        } else {
            oss << ", " << predecessor_id << "]";
        }
        return oss.str();
    }

    friend std::ostream& operator<<(
                std::ostream &os, const Vertex &vertex) {
        os << vertex.to_string();
        os.flush();
        return os;
    }
};

struct distance_comparator {
    bool operator() (const Vertex *a, const Vertex *b) {
        return a->distance > b->distance;
    }
};

#endif
