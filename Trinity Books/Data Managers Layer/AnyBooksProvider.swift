protocol AnyBooksProvider {
    
    func performBookSearch(term: String, callback: ResultOperationCallback<[Book]>)
}
