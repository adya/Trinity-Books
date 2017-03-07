struct SearchBooksViewModel : AnyBooksViewModel {
    var books: [AnyBookViewModel]?
    
    let emptyMessage: AnyMessageCellDataSource
    
    let loadingMessage = try! Injector.inject(AnyMessageCellDataSource.self, with: "Searching...")
    let loadingMoreMessage = try! Injector.inject(AnyMessageCellDataSource.self, with: "Loading more...")
    
    var isLoading: Bool = false
    
    var hasMore: Bool
    
    init(books: [Book]? = nil) {
        self.books = books?.map{try! Injector.inject(AnyBookViewModel.self, with: $0)}
        let message = books == nil ? "Start searching for books" :
                        books!.isEmpty ? "No books has been found." : ""
        emptyMessage = try! Injector.inject(AnyMessageCellDataSource.self,
                                     with: message)
        hasMore = !(books?.isEmpty ?? true)
    }
}
