protocol AnyBooksViewModel {
    var books : [AnyBookViewModel]? {get}
    
    var emptyMessage : AnyMessageCellDataSource {get}
    var loadingMessage: AnyMessageCellDataSource {get}
    
    var isLoading : Bool {get set}
}
