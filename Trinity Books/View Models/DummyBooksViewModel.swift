struct DummyBooksViewModel : AnyBooksViewModel {
    var books: [AnyBookViewModel]? = Array(repeating: DummyBookViewModel(), count: 3)

    var empty: AnyMessageCellDataSource = try! Injector.inject(AnyMessageCellDataSource.self, with: "No books here.")
}
