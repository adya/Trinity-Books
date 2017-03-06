protocol AnyBooksProvider {
    
    func performBookSearch(term: String, callback: @escaping ResultOperationCallback<[Book]>)
}
