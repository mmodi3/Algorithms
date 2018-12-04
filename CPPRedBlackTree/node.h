/*******************************************************************************
 * Name          : node.h
 * Author        : Brian S. Borowski
 * Version       : 1.2
 * Date          : October 8, 2014
 * Last modified : November 7, 2017
 * Description   : Implementation of node for a red-black tree.
 ******************************************************************************/
#ifndef NODE_H_
#define NODE_H_

#include <cstdlib>
#include <utility>

enum { RED, BLACK };
typedef unsigned char color_t;

template<typename K, typename V>
struct Node {
public:
    Node() : left{NULL}, right{NULL}, parent{NULL}, color{RED} { }

    Node(const K &key, const V &value) :
        left{NULL}, right{NULL}, parent{NULL}, color{RED},
        kv_pair_(std::make_pair(key, value)) { }

    inline const K& key() const {
        return kv_pair_.first;
    }

    inline const V& value() const {
        return kv_pair_.second;
    }

    inline void set_value(const V &value) {
        kv_pair_.second = value;
    }

    Node<K, V> *left, *right, *parent;
    color_t color;

private:
    std::pair<K, V> kv_pair_;
};

#endif /* NODE_H_ */
