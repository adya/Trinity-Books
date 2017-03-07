struct DummyBooksViewModel : AnyBooksViewModel {
    var books: [AnyBookViewModel]? = Array(repeating: DummyBookViewModel(), count: 3)

    let emptyMessage = try! Injector.inject(AnyMessageCellDataSource.self, with: "No books here.")
    
    let loadingMessage = try! Injector.inject(AnyMessageCellDataSource.self, with: "Searching...")
    let loadingMoreMessage = try! Injector.inject(AnyMessageCellDataSource.self, with: "Loading more...")
    
    var isLoading: Bool = false
    var hasMore: Bool = false
}
