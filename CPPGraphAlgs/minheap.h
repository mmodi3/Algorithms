/*******************************************************************************
 * Name          : minheap.h
 * Author        : Brian S. Borowski
 * Version       : 1.1
 * Date          : November 17, 2014
 * Last modified : October 16, 2017
 * Description   : Implementation of min heap to be used as a priority queue.
 ******************************************************************************/
#ifndef MINHEAP_H_
#define MINHEAP_H_

#include <cstdlib>
#include <string>
#include <sstream>
#include <vector>
#include <iostream>

template <typename T>
T& maybe_deref(T &x) { return x; }

template <typename T>
T& maybe_deref(T *x) { return *x; }

class heap_exception: public std::exception {
public:
    explicit heap_exception(const std::string &message) : message_(message) { }

    ~heap_exception() throw() { }

    virtual const char* what() const throw() {
        return message_.c_str();
    }

private:
    std::string message_;
};

template <typename T, typename P>
class MinHeap {
public:
    explicit MinHeap(const P &pred = P());
    explicit MinHeap(size_t default_size, const P &pred = P());
    explicit MinHeap(T elements[], size_t size, const P &pred = P());
    virtual ~MinHeap();
    inline size_t size() const;
    inline bool empty() const;
    inline void clear();
    const T& peek() const;
    T extract();
    size_t insert(const T &element);
    size_t decrease_key(size_t i, const T &key, bool check=true);
    const T& at(size_t index) const;

    friend std::ostream& operator<<(
            std::ostream &os, const MinHeap<T, P> &min_heap) {
        os << min_heap.to_string();
        os.flush();
        return os;
    }

private:
    std::vector<T> elements_;
    size_t size_;
    P pred_;

    void build_min_heap(T elements[], size_t size);
    void min_heapify(size_t i);
    std::string to_string() const;
};

#endif /* MINHEAP_H_ */

template <typename T, typename P>
MinHeap<T, P>::MinHeap(const P &pred) : size_{0}, pred_{pred} {
    elements_.reserve(16);
}

template <typename T, typename P>
MinHeap<T, P>::MinHeap(size_t default_size, const P &pred) :
                                        size_{0}, pred_{pred} {
    elements_.reserve(default_size);
}

template <typename T, typename P>
MinHeap<T, P>::MinHeap(T elements[], size_t size, const P &pred) :
                                        size_{0}, pred_{pred} {
    elements_.reserve(size);
    build_min_heap(elements, size);
}

template <typename T, typename P>
MinHeap<T, P>::~MinHeap() {
    clear();
}

template <typename T, typename P>
size_t MinHeap<T, P>::size() const {
    return size_;
}

template <typename T, typename P>
bool MinHeap<T, P>::empty() const {
    return size_ == 0;
}

template <typename T, typename P>
void MinHeap<T, P>::clear() {
    elements_.clear();
    size_ = 0;
}

template <typename T, typename P>
const T& MinHeap<T, P>::peek() const {
    if (size_ == 0) {
        throw heap_exception("Cannot peek() on empty heap.");
    }
    return elements_[0];
}

template <typename T, typename P>
T MinHeap<T, P>::extract() {
    if (size_ == 0) {
        throw heap_exception("Cannot extract() on empty heap.");
    }
    T min = elements_[0];
    --size_;
    elements_[0] = elements_[size_];
    min_heapify(0);
    return min;
}

template <typename T, typename P>
size_t MinHeap<T, P>::insert(const T &element) {
    ++size_;
    if (size_ > elements_.capacity()) {
        elements_.reserve(elements_.size() << 1);
    }
    return decrease_key(size_ - 1, element, false);
}

template <typename T, typename P>
void MinHeap<T, P>::build_min_heap(T elements[], size_t size) {
    size_ = size;
    elements_.insert(elements_.end(), &elements[0], &elements[size]);
    for (int i = (size >> 1) - 1; i >= 0; --i) {
        min_heapify(static_cast<size_t>(i));
    }
}

template <typename T, typename P>
void MinHeap<T, P>::min_heapify(size_t i) {
    size_t left = (i << 1) + 1, right = left + 1, smallest;
    if (left < size_ && pred_(elements_[i], elements_[left])) {
        smallest = left;
    } else {
        smallest = i;
    }
    if (right < size_ && pred_(elements_[smallest], elements_[right])) {
        smallest = right;
    }
    if (smallest != i) {
        std::swap(elements_[i], elements_[smallest]);
        min_heapify(smallest);
    }
}

template <typename T, typename P>
size_t MinHeap<T, P>::decrease_key(size_t i, const T &key, bool check) {
    if (check && pred_(key, elements_[i])) {
        throw heap_exception("New key is larger than current key.");
    }
    elements_[i] = key;
    size_t parent_index = (i - 1) >> 1;
    while (i > 0 && pred_(elements_[parent_index], elements_[i])) {
        std::swap(elements_[parent_index], elements_[i]);
        i = parent_index;
        parent_index = (i - 1) >> 1;
    }
    return i;
}

template <typename T, typename P>
const T& MinHeap<T, P>::at(size_t index) const {
    if (index >= size_) {
        throw heap_exception("Heap index out of range.");
    }
    return elements_[index];
}

template <typename T, typename P>
std::string MinHeap<T, P>::to_string() const {
    std::ostringstream oss;
    oss << "[";
    for (size_t i = 0; i < size_; ++i) {
        if (i != 0) {
            oss << ", ";
        }
        oss << maybe_deref(elements_[i]);
    }
    oss << "]";
    return oss.str();
}
