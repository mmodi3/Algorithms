/*******************************************************************************
 * Name          : treeprinter.h
 * Author        : Brian S. Borowski
 * Version       : 1.2
 * Date          : October 8, 2014
 * Last modified : November 8, 2017
 * Description   : Class to display binary tree with ASCII art.
 ******************************************************************************/
#ifndef TREEPRINTER_H_
#define TREEPRINTER_H_

#include "node.h"
#include <vector>
#include <sstream>
#include <climits>
#include <algorithm>

template<typename K, typename V>
class BinaryTreePrinter {

    typedef struct ascii_node {
        struct ascii_node *left, *right;

        int edge_length, // Length of the edge from this node to its children
            height,
            parent_direction; // -1 left, 0 root, 1 right

        std::string label;
    } AsciiNode;

public:
    BinaryTreePrinter(Node<K, V> *node) : print_next_{0}, root_{NULL} {
        create_ascii_tree(node);
    }

    ~BinaryTreePrinter() {
        delete_ascii_tree(root_);
        root_ = NULL;
    }

    std::string to_string() {
        return builder_.str();
    }

private:
    static const int GAP = 1;
    std::vector<int> left_profile_, right_profile_;
    int print_next_;
    std::ostringstream builder_;
    AsciiNode *root_;

    /**
     * Converts the given Node into a string containing an ASCII representation
     * of the tree.
     */
    void create_ascii_tree(Node<K, V> *node) {
        if (node == NULL) {
            builder_ << "Root is null.";
            return;
        }
        root_ = build_ascii_tree(node);
        compute_edge_lengths(root_);
        for (int i = 0; i < root_->height; ++i) {
            left_profile_.push_back(SHRT_MAX);
        }
        compute_left_profile(root_, 0, 0);
        int min_x = 0;
        for (int i = 0; i < root_->height; ++i) {
            min_x = std::min(min_x, left_profile_[i]);
        }
        int lastLine = root_->height - 1;
        for (int i = 0; i < root_->height; ++i) {
            print_next_ = 0;
            print_level(root_, -min_x, i);
            if (i != lastLine) {
                builder_ << "\n";
            }
        }

    }

    /**
     * Recursively deletes the AsciiNode tree created for displaying purposes.
     */
    void delete_ascii_tree(AsciiNode *node) {
        if (node != NULL) {
            delete_ascii_tree(node->left);
            delete_ascii_tree(node->right);
            delete node;
        }
    }

    /**
     * Make a copy of the tree using the AsciiNodes.
     */
    AsciiNode* build_ascii_tree(Node<K, V> *node) {
        if (node == NULL) {
            return NULL;
        }
        AsciiNode *asciiNode = build_ascii_tree_recursive(node);
        asciiNode->parent_direction = 0;
        return asciiNode;
    }

    /**
     * Prints the given level of the given tree, assuming that the node has the
     * given x-coordinate.
     */
    void print_level(AsciiNode *node, int x, int level) {
        if (node == NULL) {
            return;
        }
        int i, isleft = node->parent_direction == -1 ? 1 : 0;
        if (level == 0) {
            for (i = 0;
                 i < x - print_next_ -
                     ((static_cast<int>(node->label.length()) - isleft) >> 1);
                 ++i) {
                builder_ << " ";
            }
            print_next_ += i;
            builder_ << node->label;
            print_next_ += node->label.length();
        } else if (node->edge_length >= level) {
            if (node->left != NULL) {
                for (i = 0; i < x - print_next_ - level; ++i) {
                    builder_ << " ";
                }
                print_next_ += i;
                builder_ << "/";
                print_next_++;
            }
            if (node->right != NULL) {
                for (i = 0; i < x - print_next_ + level; ++i) {
                    builder_ << " ";
                }
                print_next_ += i;
                builder_ << "\\";
                print_next_++;
            }
        } else {
            print_level(node->left, x - node->edge_length - 1,
                       level - node->edge_length - 1);
            print_level(node->right, x + node->edge_length + 1,
                       level - node->edge_length - 1);
        }
    }

    AsciiNode* build_ascii_tree_recursive(Node<K, V> *node) {
        if (node == NULL) {
            return NULL;
        }

        AsciiNode *ascii_node = new AsciiNode();
        ascii_node->left = build_ascii_tree_recursive(node->left);
        ascii_node->right = build_ascii_tree_recursive(node->right);
        if (ascii_node->left != NULL) {
            ascii_node->left->parent_direction = -1;
        }
        if (ascii_node->right != NULL) {
            ascii_node->right->parent_direction = 1;
        }
        std::ostringstream oss, oss_second;
        oss << node->key();

        oss_second << node->value();
        if (oss.str() != oss_second.str()) {
            oss << ":" << node->value();
        }
        ascii_node->label = oss.str();

        return ascii_node;
    }

    /**
     * The following function fills in the left profile for the given tree. It
     * assumes that the center of the label of the root of this tree is located
     * at a position (x, y). It assumes that the edge length fields have been
     * computed for this tree.
     */
    void compute_left_profile(AsciiNode *node, int x, int y) {
        if (node == NULL) {
            return;
        }
        int is_left = node->parent_direction == -1 ? 1 : 0;
        left_profile_[y] =
                std::min(left_profile_[y],
                         x - (((int)node->label.length() - is_left) >> 1));
        if (node->left != NULL) {
            for (int i = 1; i <= node->edge_length; ++i) {
                left_profile_[y + i] =
                        std::min(left_profile_[y + i], x - i);
            }
        }
        compute_left_profile(node->left, x - node->edge_length - 1, y
                + node->edge_length + 1);
        compute_left_profile(node->right, x + node->edge_length + 1, y
                + node->edge_length + 1);
    }

    void compute_right_profile(AsciiNode *node, int x, int y) {
        if (node == NULL) {
            return;
        }
        int not_left = node->parent_direction != -1 ? 1 : 0;
        right_profile_[y] =
                std::max(right_profile_[y],
                         x + (((int)node->label.length() - not_left) >> 1));
        if (node->right != NULL) {
            for (int i = 1; i <= node->edge_length; i++) {
                right_profile_[y + i] =
                        std::max(right_profile_[y + i], x + i);
            }
        }
        compute_right_profile(node->left, x - node->edge_length - 1, y
                + node->edge_length + 1);
        compute_right_profile(node->right, x + node->edge_length + 1, y
                + node->edge_length + 1);
    }

    /**
     * Fills in the edgeLength and height fields of the specified node.
     */
    void compute_edge_lengths(AsciiNode *node) {
        if (node == NULL) {
            return;
        }
        compute_edge_lengths(node->left);
        compute_edge_lengths(node->right);

        // First fill in the edge length of the node.
        if (node->right == NULL && node->left == NULL) {
            node->edge_length = 0;
        } else {
            int min_h;
            if (node->left != NULL) {
                for (int i = 0; i < node->left->height; ++i) {
                    right_profile_.push_back(SHRT_MIN);
                }
                compute_right_profile(node->left, 0, 0);
                min_h = node->left->height;
            } else {
                min_h = 0;
            }
            if (node->right != NULL) {
                for (int i = 0; i < node->right->height; ++i) {
                    left_profile_.push_back(SHRT_MAX);
                }
                compute_left_profile(node->right, 0, 0);
                min_h = std::min(node->right->height, min_h);
            } else {
                min_h = 0;
            }
            int delta = 4;
            for (int i = 0; i < min_h; i++) {
                delta = std::max(delta,
                            GAP + 2 + right_profile_[i] - left_profile_[i]);
            }

            // If the node has two children of height 1, we allow the two leaves
            // to be within 1 instead of 2.
            if (( (node->left != NULL && node->left->height == 1) ||
                  (node->right != NULL && node->right->height == 1) )
                    && delta > 4) {
                delta--;
            }

            node->edge_length = ((delta + 1) >> 1) - 1;
        }

        // Now fill in the height of the node.
        int h = 1;
        if (node->left != NULL) {
            h = std::max(node->left->height + node->edge_length + 1, h);
        }
        if (node->right != NULL) {
            h = std::max(node->right->height + node->edge_length + 1, h);
        }
        node->height = h;
    }
};

#endif /* TREEPRINTER_H_ */
