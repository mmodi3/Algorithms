/*******************************************************************************
 * Name          : unweightedgraph.cpp
 * Author        : Brian S. Borowski
 * Version       : 1.1
 * Date          : September 27, 2014
 * Last modified : October 16, 2017
 * Description   : Graph class with 0-weights assigned to edges.
 ******************************************************************************/
#include "unweightedgraph.h"
#include <iomanip>

using namespace std;

UnweightedGraph::UnweightedGraph() : Graph() { }

UnweightedGraph::~UnweightedGraph() { }

void UnweightedGraph::add_undirected_edge(
        const vertex_id src, const vertex_id dst) {
    add_directed_edge(src, dst);
    add_directed_edge(dst, src);
}

void UnweightedGraph::add_directed_edge(
        const vertex_id src, const vertex_id dst) {
    for (int i = 0, len = src - adjacency_list_.size() + 1; i < len; ++i) {
        adjacency_list_.push_back(list<vertex_weight_pair>());
    }
    list<vertex_weight_pair> * const adjacent_vertices = &adjacency_list_[src];
    size_t len = adjacent_vertices->size();
    if (len == 0) {
        // Add one to the vertex count, since this source node has never been
        // seen before.
        ++num_vertices_;
    }

    auto it = adjacent_vertices->cbegin();
    while (it != adjacent_vertices->cend()) {
        if (it->first == dst) {
            return;
        } else if (it->first > dst) {
            break;
        }
        ++it;
    }

    adjacent_vertices->insert(it, make_pair(dst, 0));
    // Add one to the vertex count for the destination.
    ++num_vertices_;
    ++num_edges_;
}

string UnweightedGraph::to_string() const {
    std::stringstream ss;
    size_t len = adjacency_list_.size(), col_width = Graph::num_digits(len);
    for (size_t i = 1; i < len; ++i) {
        if (i != 1) {
            ss << endl;
        }
        ss << setw(col_width) << i << " -> [";
        for (auto it = adjacency_list_[i].begin();
                it != adjacency_list_[i].end(); ++it) {
            if (it != adjacency_list_[i].begin()) {
                ss << ", ";
            }
            ss << it->first;
        }
        ss << "]";
    }
    return ss.str();
}
