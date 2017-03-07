struct GoogleSearchBooksRequest : Request {
    let method = RequestMethod.get
    let url = "volumes"
    
    let parameters: [String : AnyObject]?
    
    init?(term: String, maxBooks: UInt, page: UInt) {
        guard !term.isEmpty, maxBooks > 0 && maxBooks <= 40, page >= 0 else {
            return nil
        }
        let param : [String : Any] = ["q" : term,
                      "maxResults" : maxBooks,
                      "orderBy" : "relevance",
                      "startIndex" : page,
                      "fields" : "items(id,volumeInfo(authors,description,imageLinks,subtitle,title)),totalItems",
                      "key" : "AIzaSyAx7pvaZ4G5-fceV6v9TkeZCyIdRRjW9j0"
                      
        ]
        parameters = param as [String : AnyObject]?
    }
}
