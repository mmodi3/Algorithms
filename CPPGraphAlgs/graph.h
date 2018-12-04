/*******************************************************************************
 * Name        : graph.h
 * Author      : Brian S. Borowski
 * Version     : 1.0
 * Date        : September 23, 2014
 * Description : Simple graph class.
 ******************************************************************************/
#ifndef GRAPH_H_
#define GRAPH_H_

#include "types.h"
#include <vector>
#include <list>
#include <string>
#include <sstream>
#include <vector>

class Graph {
public:
    Graph();
    virtual ~Graph();

    inline int num_vertices() const {
        return num_vertices_;
    }

    inline int num_edges() const {
        return num_edges_;
    }

    std::vector<vertex_id> get_vertices() const;
    std::vector<vertex_id> get_adjacent(vertex_id vertex) const;
    vertex_id get_highest_vertex_id() const;
    friend std::ostream& operator<<(std::ostream &os, const Graph &graph);

protected:
    int num_vertices_, num_edges_;
    std::vector< std::list<vertex_weight_pair> > adjacency_list_;

    static int num_digits(int num);
    virtual std::string to_string() const = 0;
};

#endif
