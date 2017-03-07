class GoogleBooksProvider : AnyBooksProvider {
    
    private let requestManager : RequestManager
    private let libraryManager : AnyLibraryManager

    private var searchPointer: SearchPointer!
    
    init(requestManager: RequestManager, libraryManager: AnyLibraryManager) {
        self.requestManager = requestManager
        self.libraryManager = libraryManager
    }
    
    func performBookSearch(term: String, callback: @escaping (OperationResult<[Book]>) -> Void) {
        guard !term.isEmpty else {
            callback(.failure(.invalidParameters))
            return
        }
        searchPointer = SearchPointer(term: term)
        performSearchMore(callback)
    }
    
    func performSearchMore(_ callback: @escaping (OperationResult<[Book]>) -> Void) {
        guard let searchPointer = searchPointer,
            searchPointer.page * searchPointer.pageSize <= searchPointer.total else {
            callback(.failure(.invalidParameters))
            return
        }
        
        guard let request = GoogleSearchBooksRequest(term: searchPointer.term,
                                                     maxBooks: searchPointer.pageSize,
                                                     page: searchPointer.page) else {
                                                        callback(.failure(.invalidParameters))
                                                        return
        }
        
        let call = RequestCall(request: request, responseType: GoogleBooksResponse.self) {
            switch $0 {
            case let .success(response):
                let portion = response.value
                self.searchPointer = SearchPointer(term: searchPointer.term,
                                                   total: UInt(portion.total),
                                                   page: searchPointer.page + 1)
                // check books in library.
                let books : [Book] = portion.books.map {
                    var book = $0
                    book.inLibrary = self.libraryManager.library?.books.contains(book) ?? false
                    return book
                }
                callback(.success(books))
            case .failure:
                callback(.failure(.invalidResponse))
            }
        }
        requestManager.request(call)
    }
}

private struct SearchPointer {
    let term : String
    let total : UInt
    let pageSize : UInt
    var page : UInt
    
    init(term: String, total: UInt = 0, pageSize: UInt = 20, page: UInt = 0) {
        self.term = term
        self.total = total
        self.pageSize = pageSize
        self.page = page
    }
}
