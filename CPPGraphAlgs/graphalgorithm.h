/*******************************************************************************
 * Name        : graphalgorithm.h
 * Author      : Brian S. Borowski
 * Version     : 1.0
 * Date        : September 27, 2014
 * Description : Class that implements standard graph traversal algorithms.
 ******************************************************************************/
#ifndef GRAPHALGORITHM_H_
#define GRAPHALGORITHM_H_

#include "types.h"
#include "graph.h"
#include "weightedgraph.h"
#include <vector>
#include <string>
#include <utility>

std::vector<vertex_id> breadth_first_search(const Graph * const graph);
std::vector<vertex_id> depth_first_search(const Graph * const graph);
std::vector<vertex_id> top_sort(const Graph * const graph);
std::pair<uint_t, std::string> shortest_path(
                                        vertex_id src,
                                        vertex_id dst,
                                        const WeightedGraph * const graph);

#endif
