protocol AnyCartManager {
    var cart : Cart? {get}
    
    func performLoadCart(callback: ResultOperationCallback<Cart>)
    func performAddBook(_ book: Book, callback: AnyOperationCallback)
    func performRemoveBook(_ book: Book, callback: AnyOperationCallback)
}
