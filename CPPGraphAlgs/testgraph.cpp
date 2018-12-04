/*******************************************************************************
 * Name        : testgraph.cpp
 * Author      : Brian S. Borowski
 * Version     : 1.0
 * Date        : September 23, 2014
 * Modified    : October 16, 2017
 * Description : Driver program to test graph class.
 ******************************************************************************/
#include "types.h"
#include "weightedgraph.h"
#include "unweightedgraph.h"
#include "graphalgorithm.h"
#include "vertex.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <algorithm>
#include <stdexcept>
#include <utility>
#include <climits>

using namespace std;

vector<string> split(const string& s, const string& delim,
                     const bool keep_empty = true) {
    vector<string> result;
    if (delim.empty()) {
        result.push_back(s);
        return result;
    }
    string::const_iterator substart = s.begin(), subend;
    while (true) {
        subend = search(substart, s.end(), delim.begin(), delim.end());
        string temp(substart, subend);
        if (keep_empty || !temp.empty()) {
            result.push_back(temp);
        }
        if (subend == s.end()) {
            break;
        }
        substart = subend + delim.size();
    }
    return result;
}

void add_edge(UnweightedGraph *graph, const int line_number,
              const string &data) {
    vector<string> parts = split(data, " ");
    if (parts.size() != 2) {
        ostringstream oss;
        oss << "Incorrect number of values on line " << line_number
            << ".";
        throw runtime_error(oss.str());
    }
}

void verify_value_count(const vector<string> &parts, const int line_number,
                        const size_t expected_num) {
    if (parts.size() != expected_num) {
        ostringstream oss;
        oss << "Incorrect number of values on line " << line_number << ".";
        throw runtime_error(oss.str());
    }
}

uint_t parse_data(const string &data, const int line_number,
                        const string &type) {
    istringstream iss(data);
    int value;
    if ( !( iss >> value) || value < 0 ) {
        ostringstream oss;
        oss << "Bad value '" << data << "' for " << type << " on line "
            << line_number << ".";
        throw runtime_error(oss.str());
    }
    return value;
}

UnweightedGraph *create_unweighted_graph(
        const string &filename, bool directed = false) {
    ifstream input_file(filename.c_str());
    if (!input_file) {
        throw runtime_error("Cannot open '" + filename + "'.");
    }
    input_file.exceptions(std::ifstream::badbit);
    UnweightedGraph *unweighted = new UnweightedGraph();
    try {
        string line;
        int line_number = 1;
        while (getline(input_file, line)) {
            // Right trim the string.
            line.erase(line.find_last_not_of(" \n\r\t") + 1);

            vector<string> parts = split(line, " ");
            verify_value_count(parts, line_number, 2);
            uint_t
                src = parse_data(parts[0], line_number, "source vertex"),
                dst = parse_data(parts[1], line_number, "destination vertex");
            if (directed) {
                unweighted->add_directed_edge(src, dst);
            } else {
                unweighted->add_undirected_edge(src, dst);
            }
            ++line_number;
        }
        input_file.close();
    } catch (const ifstream::failure &f) {
        delete unweighted;
        throw runtime_error(
                "An I/O error occurred reading '" + filename + "'.");
    } catch (const runtime_error &e) {
        delete unweighted;
        throw e;
    }
    return unweighted;
}

WeightedGraph *create_weighted_graph(
        const string &filename, bool directed = false) {
    ifstream input_file(filename.c_str());
    if (!input_file) {
        throw runtime_error("Cannot open '" + filename + "'.");
    }
    input_file.exceptions(std::ifstream::badbit);
    WeightedGraph *weighted = new WeightedGraph();
    try {
        string line;
        int line_number = 1;
        while (getline(input_file, line)) {
            // Right trim the string.
            line.erase(line.find_last_not_of(" \n\r\t") + 1);

            vector<string> parts = split(line, " ");
            verify_value_count(parts, line_number, 3);
            uint_t
                src = parse_data(parts[0], line_number, "source vertex"),
                dst = parse_data(parts[1], line_number, "destination vertex"),
                weight = parse_data(parts[2], line_number, "weight");
            if (directed) {
                weighted->add_directed_edge(src, dst, weight);
            } else {
                weighted->add_undirected_edge(src, dst, weight);
            }
            ++line_number;
        }
        input_file.close();
    } catch (const ifstream::failure &f) {
        delete weighted;
        throw runtime_error(
                "An I/O error occurred reading '" + filename + "'.");
    } catch (const runtime_error &e) {
        delete weighted;
        throw e;
    }
    return weighted;
}

int main(int argc, char * const argv[]) {
    if (argc != 4 and argc != 6) {
        cerr << "Usage: " << argv[0]
             << " <graph type> <algorithm> <filename> [src dst]" << endl;
        cerr << "   <graph type> = \"weighted\" | \"unweighted\" |"
             << " \"weighted_d\" | \"unweighted_d\"" << endl;
        cerr << "   <algorithm>  = \"bfs\" | \"dfs\" | \"top\" | \"shpath\""
             << endl;
        cerr << "   <filename>   = name of file containing graph data" << endl;
        cerr << "   [src dst]    = "
             << "source and destination vertices for shortest path" << endl;
        return 1;
    }

    string graph_type(argv[1]);
    if (graph_type != "weighted" && graph_type != "unweighted" &&
            graph_type != "weighted_d" && graph_type != "unweighted_d") {
        cerr << "Error: Unrecognized graph type '" << graph_type << "'."
             << endl;
        return 1;
    }
    string algorithm(argv[2]);
    if (algorithm != "bfs" && algorithm != "dfs" && algorithm != "top" &&
        algorithm != "shpath") {
        cerr << "Error: Unrecognized algorithm '" << algorithm << "'." << endl;
        return 1;
    }

    Graph *graph;
    bool directed =
            graph_type.substr(graph_type.length() - 2, string::npos) == "_d";
    try {
        if (graph_type.substr(0, 6) == "weight") {
            graph = create_weighted_graph(argv[3], directed);
        } else {
            if (algorithm == "shpath") {
                cerr << "Error: Cannot find shortest path on unweighted graph."
                     << endl;
                return 1;
            }
            graph = create_unweighted_graph(argv[3], directed);
        }
    } catch (exception &e) {
        cerr << "Error: " << e.what() << endl;
        return 1;
    }

    vector<vertex_id> solution_vertices;
    vertex_id src, dst;
    vector<vertex_id> v = graph->get_vertices();
    if (algorithm == "shpath") {
        if (argc != 6) {
            cerr << "Error: Missing [src dst] pair for shortest path." << endl;
            goto cleanup;
        }
        istringstream iss(argv[4]);
        int temp;
        uint_t first = v[0], last = v[v.size() - 1];
        if (!(iss >> temp) || temp < (signed)first || temp > (signed)last) {
            cerr << "Error: Source value must be an integer between "
                 << first << " and " << last << "." << endl;
            goto cleanup;
        }
        src = temp;

        iss.str(argv[5]);
        iss.clear();
        if (!(iss >> temp) || temp < (signed)first || temp > (signed)last) {
            cerr << "Error: Destination value must be an integer between "
                 << first << " and " << last << "." << endl;
            goto cleanup;
        }
        dst = temp;
    }

    cout << *graph << endl;

    if (algorithm == "bfs") {
        solution_vertices = breadth_first_search(graph);
        cout << "Breadth-first search: ";
    } else if (algorithm == "dfs") {
        solution_vertices = depth_first_search(graph);
        cout << "Depth-first search: ";
    } else if (algorithm == "top") {
        solution_vertices = top_sort(graph);
        cout << "Topological sort: ";
    } else if (algorithm == "shpath") {
        pair<uint_t, string> shpath =
                shortest_path(src, dst, static_cast<WeightedGraph *>(graph));
        if (shpath.first != UINT_MAX) {
            cout << "Shortest path: " << shpath.first
                 << ((shpath.first == 1) ? " unit, [" : " units, [")
                 << shpath.second << "]" << endl;
        } else {
            cout << "Shortest path: " << shpath.second << endl;
        }
        goto cleanup;
    }
    if (solution_vertices.size() == 0) {
        cout << "impossible" << endl;
    } else {
        for (auto it = solution_vertices.cbegin();
                it != solution_vertices.cend(); ++it) {
            if (it != solution_vertices.cbegin()) {
                cout << " ";
            }
            cout << *it;
        }
        cout << endl;
    }

cleanup:
    delete graph;
    return 0;
}
