import UIKit

class BaseBooksViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bookAddedHandler),
                                               name: Notification.Name(rawValue: LibraryNotification.bookAdded.rawValue),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bookRemovedHandler),
                                               name: Notification.Name(rawValue: LibraryNotification.bookRemoved.rawValue),
                                               object: nil)

    }
    
    @objc private func bookAddedHandler(notification: Notification) {
        guard let book = notification.object as? Book else {
            print("\(type(of: self)): Invalid notification received: No book attached.")
            return
        }
        
        bookHasBeenAdded(book)
    }
    
    @objc private func bookRemovedHandler(notification: Notification) {
        guard let book = notification.object as? Book else {
            print("\(type(of: self)): Invalid notification received: No book attached.")
            return
        }
        bookHasBeenRemoved(book)
    }
    
    func bookHasBeenAdded(_ book: Book) {
        print("Book has been added (Notification)")
    }
    
    func bookHasBeenRemoved(_ book: Book) {
        print("Book has been removed (Notification)")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
