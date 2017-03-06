struct LibraryBooksViewModel : AnyBooksViewModel {
    var books: [AnyBookViewModel]?
    
    let emptyMessage = try! Injector.inject(AnyMessageCellDataSource.self,
                                     with: "You haven't added any books yet.")
    
    let loadingMessage = try! Injector.inject(AnyMessageCellDataSource.self,
                                       with: "Loading...")
    
    var isLoading: Bool = false
    
    init(books: [Book]? = nil) {
        self.books = books?.map{try! Injector.inject(AnyBookViewModel.self,
                                                     with: $0,
                                                     for: LibraryBooksViewModel.self)}
    }
}
