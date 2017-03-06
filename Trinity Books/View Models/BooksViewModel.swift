struct BooksViewModel : AnyBooksViewModel {
    var books: [AnyBookViewModel]?
    
    let emptyMessage: AnyMessageCellDataSource
    
    let loadingMessage = try! Injector.inject(AnyMessageCellDataSource.self, with: "Searching...")
    
    var isLoading: Bool = false
    
    init(books: [Book]? = nil) {
        self.books = books?.map{try! Injector.inject(AnyBookViewModel.self, with: $0)}
        emptyMessage = try! Injector.inject(AnyMessageCellDataSource.self,
                                     with: books == nil ? "Start searching for books" : books!.isEmpty ? "No books has been found." : "")
    }
}
