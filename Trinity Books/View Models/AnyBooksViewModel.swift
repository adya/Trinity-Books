protocol AnyBooksViewModel {
    var books : [AnyBookViewModel]? {get set}
    
    var emptyMessage : AnyMessageCellDataSource {get}
    var loadingMessage: AnyMessageCellDataSource {get}
    var loadingMoreMessage: AnyMessageCellDataSource {get}
    
    var isLoading : Bool {get set}
    var hasMore : Bool {get set}
}
