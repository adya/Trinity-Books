struct BookViewModel : AnyBookViewModel {
    let book: Book
    
    var title: String {
        return book.title + (book.subtitle != nil && !book.subtitle!.isEmpty ? ": \(book.subtitle!)" : "")
    }
    
    var author: String {
        return book.authors.joined(separator: ", ")
    }

    
    var description: String {
        return book.description
    }
    
    var coverUri: String? {
        return book.coverUri ?? thumbnailUri
    }
    
    var thumbnailUri: String? {
        return book.thumbnailUri
    }
    
    var inLibrary: Bool {
        return book.inLibrary
    }
}
