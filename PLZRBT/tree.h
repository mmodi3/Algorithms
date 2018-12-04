/*******************************************************************************
 * Name          : tree.h
 * Author        : Brian S. Borowski
 * Version       : 1.1
 * Date          : October 11, 2014
 * Last modified : April 9, 2015
 * Description   : Base class for a tree with all non-template method headers.
 ******************************************************************************/
#ifndef TREE_H_
#define TREE_H_

#include <string>

class Tree {
public:
    virtual ~Tree() { };
    virtual std::string to_ascii_drawing() = 0;
    virtual int height() const = 0;
    virtual size_t size() const = 0;
    virtual size_t leaf_count() const = 0;
    virtual size_t internal_node_count() const = 0;
    virtual size_t diameter() const = 0;
    virtual size_t max_width() const = 0;
    virtual double successful_search_cost() const = 0;
    virtual double unsuccessful_search_cost() const = 0;
};

#endif /* TREE_H_ */
