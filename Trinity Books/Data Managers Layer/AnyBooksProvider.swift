protocol AnyBooksProvider {
    
    func performBookSearch(term: String, callback: @escaping ResultOperationCallback<[Book]>)
    
    func performSearchMore(_ callback: @escaping ResultOperationCallback<[Book]>)
}
