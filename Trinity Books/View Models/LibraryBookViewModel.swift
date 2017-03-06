struct LibraryBookViewModel : AnyBookViewModel {
    let book: Book
    
    var title: String {
        return book.title
    }
    
    var author: String {
        return book.author
    }
    
    var description: String {
        return book.description
    }
    
    var coverUri: String {
        return book.coverUri
    }
    
    var thumbnailUri: String {
        return book.thumbnailUri
    }
    
    let inLibrary: Bool = false // Prevent BookCell from displaying checkmark regardless book's inLibrary flag.
}
