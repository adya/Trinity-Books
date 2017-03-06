protocol AnyCartManager {
    var cart : Cart? {get}
    
    func performLoadCart(callback: @escaping ResultOperationCallback<Cart>)
    func performAddBook(_ book: Book, callback: @escaping ResultOperationCallback<Book>)
    func performRemoveBook(_ book: Book, callback: AnyOperationCallback?)
}
