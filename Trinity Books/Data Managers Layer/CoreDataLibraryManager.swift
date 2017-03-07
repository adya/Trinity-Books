import CoreData
import Foundation

class CoreDataLibraryManager : AnyLibraryManager {
   
    fileprivate var wrappedBooks : [BookEntity]?
    fileprivate let contextProvider : CoreDataContextProvider
    
    init(contextProvider : CoreDataContextProvider) {
        self.contextProvider = contextProvider
    }
    
    var library: Library? {
        let books = wrappedBooks?.flatMap{$0.book}
        return books.flatMap{Library(books: $0)}
    }
    
    func performLoadLibrary(_ callback: @escaping (OperationResult<Library>) -> Void) {
        loadBooks()
        callback(.success(library!))
    }
    
    func performAddBook(_ book: Book, callback: @escaping (OperationResult<Book>) -> Void) {
        guard library?.books[book] == nil else {
            callback(.failure(.invalidParameters))
            return
        }
        var book = book
        book.inLibrary = true
        if addBook(book: book) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: LibraryNotification.bookAdded.rawValue), object: book)
            callback(.success(book))
        } else {
            print("\(type(of: self)): Failed to save library)")
        }
    }
    
    func performRemoveBook(_ book: Book, callback: ((OperationResult<Book>) -> Void)?) {
        guard library?.books[book] != nil else {
            callback?(.failure(.invalidParameters))
            return
        }
        var book = book
        book.inLibrary = false
        if removeBook(book: book) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: LibraryNotification.bookRemoved.rawValue), object: book)
            callback?(.success(book))
        } else {
            print("\(type(of: self)): Failed to save library)")
        }
    }
}

// MARK: - CoreData
private extension CoreDataLibraryManager {
    
    var context : NSManagedObjectContext {
        return contextProvider.context
    }
    
    func saveContext() -> Bool {
        guard context.hasChanges else {
            return true
        }
        do {
            try context.save()
            
        } catch {
            print("\(type(of: self)): \(error)")
            return false
        }
        return true
    }
    
    func loadBooks() {
        let booksFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "BookEntity")
        do {
            wrappedBooks = try context.fetch(booksFetch) as! [BookEntity]
        } catch {
            print("\(type(of: self)): \(error)")
            wrappedBooks = []
        }
    }
    
    func addBook(book: Book) -> Bool {
        let entity : BookEntity = NSEntityDescription.insertNewObject(forEntityName: "BookEntity", into: context) as! BookEntity
        entity.book = book
        if saveContext() {
            wrappedBooks?.append(entity)
            return true
        }
        return false
    }
    
    func removeBook(book: Book) -> Bool {
        guard let index = wrappedBooks?.index(where: {$0.id != nil && $0.id! == book.id}),
            let entity = wrappedBooks?[index] else {
                return false
        }
        context.delete(entity)
        if saveContext() {
            wrappedBooks?.remove(at: index)
            return true
        }
        return false
        
    }
}

private extension BookEntity {
    
    var book : Book? {
        get {
            guard let id = id,
                let title = title,
                let subtitle = subtitle,
                let authorsData = self.authors,
                let description = descr
            
                else {
                    return nil
            }
            let coverUri = self.coverUri
            let thumbnailUri = self.thumbnailUri
            let inLibrary = self.inLibrary
            let authors = NSKeyedUnarchiver.unarchiveObject(with: authorsData as Data) as! [String]
            
            return Book(id: id,
                        title: title,
                        subtitle: subtitle,
                        authors: authors,
                        description: description,
                        coverUri: coverUri,
                        thumbnailUri: thumbnailUri,
                        inLibrary: inLibrary)
        }
        set {
            id = newValue?.id
            title = newValue?.title
            subtitle = newValue?.subtitle
            authors = (newValue?.authors as? NSArray).flatMap {
                NSKeyedArchiver.archivedData(withRootObject: $0) as NSData
            }
            descr = newValue?.description
            coverUri = newValue?.coverUri
            thumbnailUri = newValue?.thumbnailUri
            inLibrary = newValue?.inLibrary ?? false
        }
        
    }
}
