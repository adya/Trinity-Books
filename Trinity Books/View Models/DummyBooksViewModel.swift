struct DummyBooksViewModel : AnyBooksViewModel {
    let books: [AnyBookViewModel]? = Array(repeating: DummyBookViewModel(), count: 3)

    let emptyMessage = try! Injector.inject(AnyMessageCellDataSource.self, with: "No books here.")
    
    let loadingMessage = try! Injector.inject(AnyMessageCellDataSource.self, with: "Searching...")
    
    var isLoading: Bool = false
}
