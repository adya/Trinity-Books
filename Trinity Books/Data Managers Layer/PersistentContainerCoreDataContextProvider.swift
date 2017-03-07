import CoreData

@available(iOS 10.0, *)
class PersistentContainerCoreDataContextProvider : CoreDataContextProvider {
    
    var context : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    private let container : NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "library")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("\(type(of: self)): \(error)")
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
            } else {
                self.context = self.container.newBackgroundContext()
            }
        })
    }
}
