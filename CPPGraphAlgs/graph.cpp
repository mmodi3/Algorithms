/*******************************************************************************
 * Name          : graph.h
 * Author        : Brian S. Borowski
 * Version       : 1.1
 * Date          : September 23, 2014
 * Last modified : October 16, 2017
 * Description   : Simple graph class.
 ******************************************************************************/
#include "graph.h"
#include <list>
#include <vector>
#include <set>
#include <utility>
#include <sstream>
#include <algorithm>

using namespace std;

Graph::Graph() : num_vertices_{0}, num_edges_{0} {
	adjacency_list_.push_back(list<vertex_weight_pair>());
}

Graph::~Graph() { }

vector<vertex_id> Graph::get_vertices() const {
    set<vertex_id> vertex_set;
    for (size_t i = 1, len = adjacency_list_.size(); i < len; ++i) {
        vertex_set.insert(static_cast<vertex_id>(i));
        if (adjacency_list_[i].size() > 0) {
            for (const auto &adjacent : adjacency_list_[i]) {
                vertex_set.insert(adjacent.first);
            }
        }
    }
    vector<vertex_id> vertices;
    vertices.reserve(vertex_set.size());
    copy(vertex_set.begin(), vertex_set.end(), back_inserter(vertices));
    return vertices;
}

vector<vertex_id> Graph::get_adjacent(vertex_id vertex) const {
    vector<vertex_id> adjacent_ids;
    if (vertex < adjacency_list_.size()) {
        for (const auto &adjacent : adjacency_list_[vertex]) {
            adjacent_ids.push_back(adjacent.first);
        }
    }
    return adjacent_ids;
}

vertex_id Graph::get_highest_vertex_id() const {
    vector<vertex_id> v = get_vertices();
    return v[v.size() - 1];
}

ostream& operator<<(std::ostream &os, const Graph &graph) {
    os << graph.to_string();
    os.flush();
    return os;
}

int Graph::num_digits(int num) {
    int count = 1;
    while (num > 9) {
        num /= 10;
        ++count;
    }
    return count;
}
