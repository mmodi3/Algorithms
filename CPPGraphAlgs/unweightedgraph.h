/*******************************************************************************
 * Name        : unweightedgraph.h
 * Author      : Brian S. Borowski
 * Version     : 1.0
 * Date        : September 27, 2014
 * Description : Graph class with 0-weights assigned to edges.
 ******************************************************************************/
#ifndef UNWEIGHTEDGRAPH_H_
#define UNWEIGHTEDGRAPH_H_

#include "types.h"
#include "graph.h"

class UnweightedGraph : public Graph {
public:
    explicit UnweightedGraph();
    ~UnweightedGraph();

    void add_directed_edge(const vertex_id src, const vertex_id dst);

    void add_undirected_edge(const vertex_id src, const vertex_id dst);

private:
    std::string to_string() const;
};

#endif
