import Foundation

public final class AKCache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifeTime: TimeInterval
    private let keyTracker: KeyTracker
    
    init(
        dateProvider: @escaping () -> Date = Date.init,
        entryLifeTime: TimeInterval = 12 * 60 * 60,
        maximumEntryCount: Int = 50
    ) {
        self.dateProvider = dateProvider
        self.entryLifeTime = entryLifeTime
        self.keyTracker = KeyTracker()
        self.wrapped.delegate = keyTracker
        self.wrapped.countLimit = maximumEntryCount
    }
}
//MARK: - API Implementation
extension AKCache {
    func insert(key: Key, value: Value) {
        let entry = Entry(
            key: key,
            val: value,
            expirationDate: dateProvider().addingTimeInterval(entryLifeTime)
        )
        insert(entry)
    }
    
    private func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
    
    func value(for key: Key) -> Value? {
        if let entry = wrapped.object(forKey: WrappedKey(key)) {
            if dateProvider() < entry.expirationDate {
                return entry.value
            } else {
                remove(key: key)
            }
        }
        return nil
    }
    
    // 7799511020
    
    fileprivate func entry(forKey key: Key) -> Entry? {
        if let entry = wrapped.object(forKey: WrappedKey(key)) {
            if dateProvider() < entry.expirationDate {
                return entry
            } else {
                remove(key: key)
            }
        }
        return nil
    }
    
    func remove(key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
    
    func isKeyExist(key: Key) -> Bool {
        return keyTracker.keys.contains(key)
    }
    
    func removeAll() {
        wrapped.removeAllObjects()
    }
    
    subscript(key: Key) -> Value? {
        get {
            value(for: key)
        }
        set {
            if let value = newValue {
                insert(key: key, value: value)
            } else {
                remove(key: key)
            }
        }
    }
}
extension AKCache: Codable where Key: Codable, Value: Codable {
    convenience public init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }
    
    func saveToDisk(withName name: String, using fileManager: FileManager = .default) throws {
        let folderUrls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderUrls[0].appendingPathComponent(name + ".cache")
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }
    
    func readFromDisk(withName name: String, using fileManager: FileManager = .default) throws {
        let folderUrls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderUrls[0].appendingPathComponent(name + ".cache")
        let entries = try JSONDecoder().decode([Entry].self, from: .init(contentsOf: fileURL))
        entries.forEach(insert)
    }
}
extension AKCache {
    fileprivate class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) {
            self.key = key
        }
        
        override var hash: Int {
            return self.key.hashValue
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let obj = object as? WrappedKey else {
                return false
            }
            return obj.key == key
        }
    }
}
extension AKCache {
    fileprivate final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date
        
        init(key: Key, val: Value, expirationDate: Date) {
            self.key = key
            self.value = val
            self.expirationDate = expirationDate
        }
    }
}
extension AKCache.Entry: Codable where Key: Codable, Value: Codable {}
extension AKCache {
    fileprivate class KeyTracker:NSObject, NSCacheDelegate {
        var keys = Set<Key>()
        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            if let entry = obj as? Entry {
                keys.remove(entry.key)
            }
        }
    }
}

//class Item: NSDiscardableContent {
//    func beginContentAccess() -> Bool {
//        <#code#>
//    }
//
//    func endContentAccess() {
//        <#code#>
//    }
//
//    func discardContentIfPossible() {
//        <#code#>
//    }
//
//    func isContentDiscarded() -> Bool {
//        <#code#>
//    }
//}
