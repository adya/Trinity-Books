class BaseStorage : TSStorage {
    fileprivate let storage : StorageProvider
    
    var count : Int {
        get {
            return storage.count
        }
    }
    
    init(storage: StorageProvider){
        self.storage = storage
    }
    
    func saveObject(_ object: Any, forKey key: String) {
        storage[key] = object
    }
    
    func loadObjectForKey(_ key: String) -> Any? {
        return storage[key]
    }
    
    func popObjectForKey(_ key: String) -> Any? {
        if let obj = self.loadObjectForKey(key) {
            self.removeObjectForKey(key)
            return obj
        }
        return nil
    }
    
    func removeObjectForKey(_ key: String) {
        storage[key] = nil
    }
    
    func removeAllObjects() {
        storage.removeAll()
    }
    
    func hasObjectForKey(_ key: String) -> Bool {
        return (self.loadObjectForKey(key) != nil)
    }
}
