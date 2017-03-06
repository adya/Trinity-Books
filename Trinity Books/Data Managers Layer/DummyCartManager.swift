import Foundation

class DummyCartManager : AnyCartManager {
    var cart: Cart?
    
    func performLoadCart(callback: @escaping ResultOperationCallback<Cart>) {
        cart = dummy
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            callback(.success(self.cart!))
        }
    }
    
    func performAddBook(_ book: Book, callback: @escaping (OperationResult<Book>) -> Void) {
        guard cart?.books[book] == nil else {
            callback(.failure(.invalidParameters))
            return
        }
        var book = book
        book.inLibrary = true
        cart?.books.append(book)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            callback(.success(book))
        }
    }
    
    func performRemoveBook(_ book: Book, callback: ((AnyOperationResult) -> Void)?) {
        guard cart?.books[book] == nil else {
            callback?(.failure(.invalidParameters))
            return
        }
        cart?.books[book] = nil
        callback?(.success)
    }
}

private extension DummyCartManager {
    var dummy : Cart {
        return Cart(books: [
            Book(id: 1,
                 title: "The Lord of the Rings",
                 author: "John Ronald Reuel Tolkien",
                 description: "The Lord of the Rings is an epic high fantasy trilogy written by English philologist and University of Oxford professor J.R.R. Tolkien. The story began as a sequel to Tolkien's earlier, less complex children's fantasy novel 'The Hobbit' (1937), but eventually developed into a much larger work which formed the basis for the extended Middle-Earth Universe. It was written in stages between 1937 and 1949, much of it during World War II. It is the third best-selling novel ever written, with over 150 million copies sold.",
                 coverUri: "http://cdn.collider.com/wp-content/uploads/2016/07/the-lord-of-the-rings-book-cover.jpg",
                 thumbnailUri: "http://cdn.collider.com/wp-content/uploads/2016/07/the-lord-of-the-rings-book-cover.jpg",
                 inLibrary: true)
            ])
    }
}
