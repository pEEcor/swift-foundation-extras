//
//  MemoryCache.swift
//
//
//  Created by Paavo Becker on 31.07.22.
//

import Foundation

/// This extension should be save, since Appls explicitly mentions the thread safety of ``NSCache``
/// in its documentaion.
extension NSCache: @unchecked Sendable {}

/// A cache that places its elements in the main memory
///
/// The cache stores values of a specific type. If different types need to be stored in the Cache,
/// consider using the ``Data`` type as the cache's storage type.
///
/// The ``FileCache`` does not give any guarantee about the duration of element storage inside the
/// cache. According to the availability of system resources, elements may be evicted from the cache
/// at any time.
public final class MemoryCache<Key: Hashable, Value> {
    private let cache: NSCache<WrappedKey, Entry>
    private let keyTracker: KeyTracker
    
    /// Creates a volatile cache that holds its values in memory
    ///
    /// - Parameter initialValues: Dictionary with initial content. Defaults to empty dictionary
    public init(initialValues: [Key: Value] = [:]) {
        self.cache = NSCache()
        self.keyTracker = KeyTracker()
        
        self.cache.delegate = self.keyTracker
        
        // Insert initial values into the cache
        initialValues.forEach { key, value in
            self.insert(value, forKey: key)
        }
    }
    
    private func entry(forKey key: Key) -> Entry? {
        self.cache.object(forKey: WrappedKey(key))
    }
}

extension MemoryCache: Cache {
    public var content: [Key: Value] {
        self.keyTracker.all
            .compactMap { self.entry(forKey: $0) }
            .reduce(into: [:], { $0[$1.key] = $1.value })
    }
    
    public func clear() {
        self.cache.removeAllObjects()
    }
    
    public func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(key: key, value: value)
        self.cache.setObject(entry, forKey: WrappedKey(key))
        self.keyTracker.insert(key: key)
    }

    public func value(forKey key: Key) -> Value? {
        self.entry(forKey: key)?.value
    }

    public func removeValue(forKey key: Key) {
        self.cache.removeObject(forKey: WrappedKey(key))
    }
}

extension MemoryCache {
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            
            return value.key == key
        }
    }
    
    final class Entry {
        let key: Key
        let value: Value
        
        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }
    
    final class KeyTracker: NSObject, NSCacheDelegate {
        private var keys = Set<Key>()
        
        var all: Set<Key> {
            keys
        }

        func cache(
            _ cache: NSCache<AnyObject, AnyObject>,
            willEvictObject object: Any
        ) {
            guard let entry = object as? Entry else {
                return
            }
            
            keys.remove(entry.key)
        }
        
        func insert(key: Key) {
            self.keys.insert(key)
        }
    }
}
