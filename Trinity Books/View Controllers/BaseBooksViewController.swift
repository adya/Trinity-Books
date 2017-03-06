import UIKit

class BaseBooksViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bookAddedHandler),
                                               name: Notification.Name(rawValue: BookDetailsNotification.bookAdded.rawValue),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bookRemovedHandler),
                                               name: Notification.Name(rawValue: BookDetailsNotification.bookRemoved.rawValue),
                                               object: nil)

    }
    
    @objc private func bookAddedHandler(notification: Notification) {
        guard let book = notification.object as? Book else {
            print("Invalid notification received: No book attached.")
            return
        }
        
        bookHasBeenAdded(book)
    }
    
    @objc private func bookRemovedHandler(notification: Notification) {
        guard let book = notification.object as? Book else {
            print("Invalid notification received: No book attached.")
            return
        }
        bookHasBeenRemoved(book)
    }
    
    func bookHasBeenAdded(_ book: Book) {}
    
    func bookHasBeenRemoved(_ book: Book) {}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
