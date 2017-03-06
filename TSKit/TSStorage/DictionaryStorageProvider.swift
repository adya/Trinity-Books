class DictionaryStorageProvider : StorageProvider {
    fileprivate var dic = [String : Any]()
    
    subscript(key : String) -> Any? {
        get {
            return dic[key]
        }
        set {
            dic[key] = newValue
        }
    }
    
    func removeAll() {
        dic.removeAll()
    }
    
    var count: Int {
        get {
            return dic.count
        }
    }
    
    var dictionary: [String : Any] {
        return dic
    }
}
