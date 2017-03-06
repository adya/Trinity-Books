struct Library {
    var books : [Book] = []
}

extension Library : Archivable {
    
    init?(fromArchive archive: [String : AnyObject]) {
        guard let books = archive[Keys.books.rawValue] as? [[String : AnyObject]] else {
            return nil
        }
        self.init(books: books.flatMap{Book(fromArchive: $0)})
    }
    
    func archived() -> [String : AnyObject] {
        let archive : [String : AnyObject] = [
            Keys.books.rawValue : books.map{$0.archived()} as AnyObject
        ]
        return archive
    }
}

private enum Keys : String {
    case books = "kBooks"
}
