import Foundation

/// `NSUserDefaults` storage data source.
class UserDefaultsStorageProvider : StorageProvider {
    fileprivate var storage = UserDefaults.standard
    
    subscript(key : String) -> Any? {
        set {
            if newValue == nil {
                storage.removeObject(forKey: key)
            } else {
                storage.set(newValue, forKey: key)
            }
        }
        get {
            return storage.object(forKey: key)
        }
    }
    
    func removeAll() {
        if let id = Bundle.main.bundleIdentifier {
            storage.removePersistentDomain(forName: id)
        }
    }
    
    var count: Int {
        get {
            return storage.dictionaryRepresentation().count
        }
    }
    
    var dictionary: [String : Any]{
        return storage.dictionaryRepresentation()
    }
    deinit {
        storage.synchronize()
    }
}
