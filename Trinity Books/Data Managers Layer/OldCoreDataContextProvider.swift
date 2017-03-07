import CoreData
import Foundation

class OldCoreDataContextProvider : CoreDataContextProvider {
    var context: NSManagedObjectContext
    
    init() {
        guard let mom = NSManagedObjectModel.mergedModel(from: nil) else {
            print("Error initializing NSManagedObjectModel.")
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            return
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        DispatchQueue.global(qos: .background).async {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex - 1]
            let storeURL = docURL.appendingPathComponent("library.sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch {
                print("Error migrating store: \(error)")
            }
        }
    }
    

}
