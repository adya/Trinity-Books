struct GoogleBooksResponse : Response {
    let request: Request
    let value: BooksPortion
    
    init?(request: Request, body: Any) {
        self.request = request
        
        let converter = try! Injector.inject(ResponseConverter<Book>.self)
        
        guard let response = body as? [String : AnyObject],
         let total = response["totalItems"] as? Int,
            let itemsDic = response["items"] as? [[String : AnyObject]] else {
                return nil
        }
        
        value = BooksPortion(books: itemsDic.flatMap{converter.convert($0)}, total: total)
    }
}
