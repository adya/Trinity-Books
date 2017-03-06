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
    
    func performRemoveBook(_ book: Book, callback: ((OperationResult<Book>) -> Void)?) {
        guard cart?.books[book] != nil else {
            callback?(.failure(.invalidParameters))
            return
        }
        cart?.books[book] = nil
        var book = book
        book.inLibrary = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            callback?(.success(book))
        }
    }
}

private extension DummyCartManager {
    var dummy : Cart {
        return Cart(books: DummyBooksProvider.dummies.random(3).map{
            var book = $0
            book.inLibrary = true
            return book
        })
    }
}
