import Foundation

/**
 *  Author:     AdYa
 *  Version:    3.1b
 *  iOS:        2.0+
 *  Date:       08/21/2016
 *  Status:     Completed
 *
 *  Description:
 *
 *  TSStorage protocol represents a common way to save values in storages of any kind.
 */
public protocol TSStorage : class {
    
    /** Convinient way to access stored values. 
     *  @param key Key associated with an object.
     */
    subscript(key : String) -> Any? {get set}
    
    /** Number of stored objects.
     *  @return Returns number of stored objects.
     */
    var count : Int {get}
    
    /** Saves object in storage and associates it with given key.
     *  @param object Object to be saved.
     *  @param key Key associated with an object.
     */
    func saveObject(_ object: Any, forKey key: String)
   
    /** Loads object associated with given key.
     *  @param key Key associated with an object.
     *  @return Returns object if any or nil.
     */
    func loadObjectForKey(_ key: String) -> Any?
    
    /** Loads object associated with given key and if exists - removes it from storage.
     *  @param key Key associated with an object.
     *  @return Returns object if any or nil.
     */
    func popObjectForKey(_ key: String) -> Any?
    
    /** Removes object associated with specified key.
     *  @param key Key associated with an object.
     */
    func removeObjectForKey(_ key: String)
    
    /** Removes all objects from the storage. */
    func removeAllObjects()
    
    /** Checks whether the object, associated with given key, exists in storage.
     *  @param key Key associated with an object.
     *  @return Returns YES if object exists.
     */
    func hasObjectForKey(_ key: String) -> Bool
}

public extension TSStorage {
    public subscript(key : String) -> Any? {
        get {
            return loadObjectForKey(key)
        }
        set {
            if let value = newValue {
                saveObject(value, forKey: key)
            } else {
                removeObjectForKey(key)
            }
        }
    }
}

struct Storage {
    static let local : TSStorage = TSStorageProvider.localStorage
    static let temp : TSStorage = TSStorageProvider.tempStorage
    static let remote : TSStorage = TSStorageProvider.remoteStorage
}

private class TSStorageProvider {
    static fileprivate var tempStorage : TSStorage = BaseStorage(storage:DictionaryStorageProvider())
    static fileprivate var localStorage : TSStorage = BaseStorage(storage: UserDefaultsStorageProvider())
    static fileprivate var remoteStorage : TSStorage = BaseStorage(storage: UbiquitousStorageProvider())
}
