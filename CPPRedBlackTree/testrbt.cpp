/*******************************************************************************
 * Name          : testrbt.cpp
 * Author        : Brian S. Borowski
 * Version       : 1.2.1
 * Date          : October 8, 2014
 * Last modified : June 19, 2017
 * Description   : Driver program to test implementation of red-black tree.
 ******************************************************************************/
#include "rbtree.h"
#include <iostream>
#include <sstream>
#include <iomanip>
#include <sstream>
#include <string>

using namespace std;

template <typename K, typename V>
string inorder_traversal(Tree *tree) {
    RedBlackTree<K, V> *rbt = static_cast<RedBlackTree<K, V> *>(tree);
    ostringstream oss;
    oss << "[";
    typename RedBlackTree<K, V>::iterator it = rbt->begin();
    while (it != rbt->end()) {
        if (it != rbt->begin()) {
            oss << ", ";
        }
        oss << it->key();
        ++it;
    }
    oss << "]";
    return oss.str();
}

template <typename K, typename V>
void test_find(Tree *tree) {
    RedBlackTree<K, V> *rbt = static_cast<RedBlackTree<K, V> *>(tree);
    typename RedBlackTree<K, V>::iterator it = rbt->begin();
    while (it != rbt->end()) {
        const K& key = it->key();
        if (rbt->find(key) == rbt->end()) {
            ostringstream oss;
            oss << "Cannot find key '" << key << "' in tree.";
            throw tree_exception(oss.str());
        }
        ++it;
    }
}

template <typename K, typename V>
void display_stats(Tree *tree) {
    cout << tree->to_ascii_drawing() << endl << endl;
    cout << "Height:                   " << tree->height() << endl;
    cout << "Total nodes:              " << tree->size() << endl;
    cout << "Leaf count:               " << tree->leaf_count() << endl;
    cout << "Internal nodes:           " << tree->internal_node_count() << endl;
    cout << "Diameter:                 " << tree->diameter() << endl;
    cout << "Maximum width:            " << tree->max_width() << endl;
    cout << fixed;
    cout << "Successful search cost:   " << setprecision(3)
         << tree->successful_search_cost() << endl;
    cout << "Unsuccessful search cost: " << setprecision(3)
         << tree->unsuccessful_search_cost() << endl;
    cout << "Inorder traversal:        " << inorder_traversal<K, V>(tree)
         << endl;

    try {
        test_find<K, V>(tree);
    } catch (const tree_exception &te) {
        cerr << "Error: " << te.what() << endl;
    }
}

int main(int argc, char *argv[]) {
    bool using_ints = false;
    if (argc > 1) {
        istringstream iss(argv[1]);
        int value;
        if (iss >> value) {
            using_ints = true;
        }
    }

    if (using_ints) {
        RedBlackTree<int, int> *rbt = new RedBlackTree<int, int>();
        for (int i = 1; i < argc; ++i) {
            istringstream iss(argv[i]);
            int value;
            if (!(iss >> value)) {
                cerr << "Error: Invalid integer '" << argv[i]
                     << "' found at index " << i << "." << endl;
                goto cleanup;
            }
            try {
                rbt->insert(value, value);
            } catch (const tree_exception &te) {
                cerr << "Warning: " << te.what() << endl;
            }
        }
        display_stats<int, int>(rbt);
        cleanup:
            delete rbt;
    } else {
        RedBlackTree<string, string> *rbt = new RedBlackTree<string, string>();
        for (int i = 1; i < argc; ++i) {
            try {
                rbt->insert(argv[i], argv[i]);
            } catch (const tree_exception &te) {
                cerr << "Warning: " << te.what() << endl;
            }
        }
        display_stats<string, string>(rbt);
        delete rbt;
    }

    return 0;
}
