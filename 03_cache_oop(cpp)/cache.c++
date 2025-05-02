//Q: LRU policy in c++

#include <iostream>
#include <unordered_map>
#include <list>

class LRUCache {
private:
    int capacity;

    // This list stores the keys and values in order of usage.
    // Most recently used item is at the front, least recently used is at the back.
    std::list<std::pair<int, int>> cache;

    // This map helps us find items in the list quickly using their key.
    std::unordered_map<int, std::list<std::pair<int, int>>::iterator> cacheMap;

public:
    // Constructor
    LRUCache(int cap) {
        capacity = cap;
    }

    // Get value by key
    int get(int key) {
        // If the key is not found, return -1
        if (cacheMap.find(key) == cacheMap.end()) {
            return -1;
        }

        // Move the accessed item to the front of the list (most recently used)
        auto it = cacheMap[key];
        int value = it->second;

        // Remove it from its current position
        cache.erase(it);

        // Insert it at the front
        cache.push_front({key, value});
        cacheMap[key] = cache.begin();

        return value;
    }

    // Put key-value pair into the cache
    void put(int key, int value) {
        // If the key already exists, remove the old value
        if (cacheMap.find(key) != cacheMap.end()) {
            cache.erase(cacheMap[key]);
        }
        // If the cache is full, remove the least recently used item (back of the list)
        else if (cache.size() >= capacity) {
            auto last = cache.back(); // Get the last item
            cacheMap.erase(last.first); // Remove from map
            cache.pop_back(); // Remove from list
        }

        // Insert the new key-value pair at the front of the list
        cache.push_front({key, value});
        cacheMap[key] = cache.begin();
    }

    // Display contents of the cache
    void display() {
        std::cout << "Cache: ";
        for (auto &item : cache) {
            std::cout << "(" << item.first << ":" << item.second << ") ";
        }
        std::cout << "\n";
    }
};