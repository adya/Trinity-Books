struct CartBooksViewModel : AnyBooksViewModel {
    let books: [AnyBookViewModel]?
    
    let emptyMessage = try! Injector.inject(AnyMessageCellDataSource.self,
                                     with: "You haven't added any books yet.")
    
    let loadingMessage = try! Injector.inject(AnyMessageCellDataSource.self,
                                       with: "Searching...")
    
    var isLoading: Bool = false
    
    init(books: [Book]? = nil) {
        self.books = books?.map{try! Injector.inject(AnyBookViewModel.self,
                                                     with: $0,
                                                     for: CartBooksViewModel.self)}
    }
}
