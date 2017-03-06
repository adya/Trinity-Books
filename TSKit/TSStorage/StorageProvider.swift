/// Defines a key-value based way to access different storage providers.
protocol StorageProvider : class {
    
    /// Gets or sets value for given key.
    subscript(key : String) -> Any? {get set}
    
    /// Removes all stored values.
    func removeAll()
    
    /// Returns total number of stored entries.
    var count : Int {get}
    
    /// Returns dictionary representation of the storage.
    var dictionary : [String : Any] {get}
}