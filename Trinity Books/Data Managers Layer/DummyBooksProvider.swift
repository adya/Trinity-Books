import Foundation

class DummyBooksProvider : AnyBooksProvider {
    
    private let libraryManager : AnyLibraryManager
    
    init(libraryManager: AnyLibraryManager) {
        self.libraryManager = libraryManager
    }
    
    func performBookSearch(term: String, callback: @escaping (OperationResult<[Book]>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            var books : [Book]
            switch term.lowercased() {
                case "all": books = DummyBooksProvider.dummies
                case "part": books = DummyBooksProvider.dummies.random(2)
                default: books = []
            }
            // check books in library.
            books =  books.map {
                var book = $0
                book.inLibrary = self.libraryManager.library?.books.contains(book) ?? false
                return book
            }
            DispatchQueue.main.async {
                callback(.success(books))
            }
        }
    }
    
    func performSearchMore(_ callback: @escaping (OperationResult<[Book]>) -> Void) {
        callback(.success([]))
    }
}

extension DummyBooksProvider {
    static var dummies: [Book] {
        return [
            Book(id: "1",
                 title: "The Lord of the Rings",
                 subtitle: nil,
                 authors: ["John Ronald Reuel Tolkien"],
                 description: "The Lord of the Rings is an epic high fantasy trilogy written by English philologist and University of Oxford professor J.R.R. Tolkien. The story began as a sequel to Tolkien's earlier, less complex children's fantasy novel 'The Hobbit' (1937), but eventually developed into a much larger work which formed the basis for the extended Middle-Earth Universe. It was written in stages between 1937 and 1949, much of it during World War II. It is the third best-selling novel ever written, with over 150 million copies sold.",
                 coverUri: "http://cdn.collider.com/wp-content/uploads/2016/07/the-lord-of-the-rings-book-cover.jpg",
                 thumbnailUri: "http://cdn.collider.com/wp-content/uploads/2016/07/the-lord-of-the-rings-book-cover.jpg",
                 inLibrary: false),
            Book(id: "2",
                 title: "The Witcher",
                 subtitle: "The Last Wish",
                 authors: ["Andrzej Sapkowski"],
                 description: "The Last Wish is the first (in its fictional chronology; published second in original Polish) of the two collections of short stories (the other being The Sword of Destiny) preceding the main Witcher Saga, written by Polish fantasy writer Andrzej Sapkowski. The first Polish edition was published in 1993, the first English edition in 2007. The book has also been translated into several other languages.\nThe collection employs the frame story framework and contains 7 main short stories; Geralt of Rivia, after having been injured in battle, rests in a temple. During that time he has flashbacks to recent events in his life, each of which forms a story of its own.",
                 coverUri: "https://upload.wikimedia.org/wikipedia/en/1/14/Andrzej_Sapkowski_-_The_Last_Wish.jpg",
                 thumbnailUri: "https://upload.wikimedia.org/wikipedia/en/1/14/Andrzej_Sapkowski_-_The_Last_Wish.jpg",
                 inLibrary: false),
            Book(id: "3",
                 title: "The Witcher",
                 subtitle: "Sword of Destiny",
                 authors: ["Andrzej Sapkowski"],
                 description: "Sword of Destiny is the second (in its fictional chronology; first in Polish print) of the two collections of short stories (the other being The Last Wish), both preceding the main Witcher Saga. The stories were written by Polish fantasy writer Andrzej Sapkowski. The first Polish edition was published in 1992. The English edition was published by Gollancz on 21 May, 2015.",
                 coverUri: "http://4.bp.blogspot.com/-WzqM-2f9VCk/VL1JGYpbdpI/AAAAAAAAK10/4dh_citWNZw/s1600/Sword%2Bof%2BDestiny.jpg",
                 thumbnailUri: "http://4.bp.blogspot.com/-WzqM-2f9VCk/VL1JGYpbdpI/AAAAAAAAK10/4dh_citWNZw/s1600/Sword%2Bof%2BDestiny.jpg",
                 inLibrary: false)
        ]
    }
}
