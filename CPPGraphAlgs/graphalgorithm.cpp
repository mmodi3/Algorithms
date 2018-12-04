/*******************************************************************************
 * Name          : graphalgorithm.cpp
 * Author        : Brian S. Borowski
 * Version       : 1.1
 * Date          : September 27, 2014
 * Last modified : October 16, 2017
 * Description   : Class that implements standard graph traversal algorithms.
 ******************************************************************************/
#include "graphalgorithm.h"
#include "graph.h"
#include "weightedgraph.h"
#include "vertex.h"
#include "minheap.h"
#include <vector>
#include <queue>
#include <algorithm>
#include <functional>
#include <climits>
#include <stdexcept>

using namespace std;

/*
static void breadth_first_search_visit(
        vertex_id vertex, const Graph * const graph, bool *visited,
        vector<vertex_id> &order) {

}
*/

vector<vertex_id> breadth_first_search(const Graph * const graph) {
    vector<vertex_id> order;
    return order;
}


static void depth_first_search_visit(
        vertex_id vertex, const Graph * const graph, bool *visited,
        vector<vertex_id> &order) {

}


vector<vertex_id> depth_first_search(const Graph * const graph) {
    vector<vertex_id> order, vertices = graph -> get_vertices();
    size_t num_vertices = static_cast<size_t>(graph -> get_highest_vertex_id());
    order.reserve(num_vertices);
    bool *visited = new bool[num_vertices + 1];
    fill(visited, visited + num_vertices + 1, false);
    for (auto it = vertices.begin(); it != vertices.end(); ++it){
    		if(!visited[*it]){
    			depth_first_search_visit(*it, graph, visited, order);
    		}
    }
    delete [] visited;
    return order;
}

vector<vertex_id> top_sort(const Graph * const graph) {
    vector<vertex_id> order;
    return order;
}

pair<uint_t, string> shortest_path(
        vertex_id src, vertex_id dst, const WeightedGraph * const graph) {

    pair<uint_t, string> result(0, "");
    return result;
}
