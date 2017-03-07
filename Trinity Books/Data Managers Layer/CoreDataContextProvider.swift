import CoreData

protocol CoreDataContextProvider {
    var context : NSManagedObjectContext {get}
}
