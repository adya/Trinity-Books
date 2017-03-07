import Foundation

class UserDefaultsLibraryManager: AnyLibraryManager {
    var library: Library?
    
    func performLoadLibrary(_ callback: @escaping (OperationResult<Library>) -> Void) {
        if let dic = Storage.local[Keys.library.rawValue] as? [String : AnyObject],
              let library = Library(fromArchive: dic) {
            self.library = library
            callback(.success(library))
            return
        }
        library = Library(books: [])
        callback(.success(library!))
    }
    
    func performAddBook(_ book: Book, callback: @escaping (OperationResult<Book>) -> Void) {
        guard library?.books[book] == nil else {
            callback(.failure(.invalidParameters))
            return
        }
        var book = book
        book.inLibrary = true
        library?.books.append(book)
        if let library = library {
            Storage.local[Keys.library.rawValue] = library.archived()
        } else {
            print("\(type(of: self)): Failed to save library)")
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: LibraryNotification.bookAdded.rawValue), object: book)
        callback(.success(book))
    }
    
    func performRemoveBook(_ book: Book, callback: ((OperationResult<Book>) -> Void)?) {
        guard library?.books[book] != nil else {
            callback?(.failure(.invalidParameters))
            return
        }
        var book = book
        book.inLibrary = false
        library?.books[book] = nil
        if let library = library {
            Storage.local[Keys.library.rawValue] = library.archived()
        } else {
            print("\(type(of: self)): Failed to save library)")
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: LibraryNotification.bookRemoved.rawValue), object: book)
        callback?(.success(book))
    }
}

private enum Keys : String {
    case library = "kLibrary"
}
