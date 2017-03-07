import Foundation

class DummyLibraryManager : AnyLibraryManager {
    
    var library: Library?
    
    func performLoadLibrary(_ callback: @escaping ResultOperationCallback<Library>) {
        library = dummy
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            callback(.success(self.library!))
        }
    }
    
    func performAddBook(_ book: Book, callback: @escaping (OperationResult<Book>) -> Void) {
        guard library?.books[book] == nil else {
            callback(.failure(.invalidParameters))
            return
        }
        var book = book
        book.inLibrary = true
        library?.books.append(book)
        NotificationCenter.default.post(name: Notification.Name(rawValue: LibraryNotification.bookAdded.rawValue), object: book)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            callback(.success(book))
        }
    }
    
    func performRemoveBook(_ book: Book, callback: ((OperationResult<Book>) -> Void)?) {
        guard library?.books[book] != nil else {
            callback?(.failure(.invalidParameters))
            return
        }
        library?.books[book] = nil
        var book = book
        book.inLibrary = false
         NotificationCenter.default.post(name: Notification.Name(rawValue: LibraryNotification.bookRemoved.rawValue), object: book)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            callback?(.success(book))
        }
    }
}

private extension DummyLibraryManager {
    var dummy : Library {
        return Library(books: DummyBooksProvider.dummies.random(2).map{
            var book = $0
            book.inLibrary = true
            return book
        })
    }
}
