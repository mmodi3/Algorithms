/*******************************************************************************
 * Name        : weightedgraph.h
 * Author      : Brian S. Borowski
 * Version     : 1.0
 * Date        : September 27, 2014
 * Description : Graph class with non-negative weights assigned to edges.
 ******************************************************************************/
#ifndef WEIGHTEDGRAPH_H_
#define WEIGHTEDGRAPH_H_

#include "types.h"
#include "graph.h"

class WeightedGraph : public Graph {
public:
    explicit WeightedGraph();
    ~WeightedGraph();

    void add_directed_edge(
            const vertex_id src, const vertex_id dst, const uint_t weight);

    void add_undirected_edge(
            const vertex_id src, const vertex_id dst, const uint_t weight);

    uint_t get_weight(const vertex_id src, const vertex_id dst) const;

private:
    std::string to_string() const;
};

#endif
