protocol AnyLibraryManager {
    var library : Library? {get}
    
    func performLoadLibrary(callback: @escaping ResultOperationCallback<Library>)
    func performAddBook(_ book: Book, callback: @escaping ResultOperationCallback<Book>)
    func performRemoveBook(_ book: Book, callback: ResultOperationCallback<Book>?)
}

enum LibraryNotification : String {
    case bookAdded = "kNotificationBookAdded"
    case bookRemoved = "kNotificationBookRemoved"
}
