import UIKit

enum BookDetailsNotification : String {
    case bookAdded = "kNotificationBookAdded"
    case bookRemoved = "kNotificationBookRemoved"
}

class BookDetailsViewController: UIViewController {
    
    let manager = try! Injector.inject(AnyCartManager.self)
    
    func setBook(_ book : Book) {
        viewModel = try! Injector.inject(AnyBookViewModel.self, with: book)
        if isViewLoaded {
            configure(with: viewModel)
        }
    }
    
    fileprivate var viewModel : AnyBookViewModel!
    
    @IBOutlet weak fileprivate var bCart: UIButton!
    @IBOutlet weak fileprivate var tvDescription: UITextView!
    @IBOutlet weak fileprivate var ivCover: UIImageView!
    @IBOutlet weak fileprivate var aiLoadingCover: UIActivityIndicatorView!
    @IBOutlet weak fileprivate var lAuthor: UILabel!
    @IBOutlet weak fileprivate var aiAddingBook: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure(with: viewModel)
    }
   
    
}

// MARK: - Interactor
private extension BookDetailsViewController {
    func addToCart(book: Book, completion: @escaping () -> Void) {
        showLoading()
        manager.performAddBook(book) {
            self.hideLoading()
            switch $0 {
            case let .success(updatedBook):
                self.setBook(updatedBook)
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: BookDetailsNotification.bookAdded.rawValue),
                                                             object: updatedBook,
                                                             userInfo: nil))
                completion()
            case let .failure(error):
                guard error != .invalidParameters else {
                    print("Book is already in the cart")
                    return
                }
                
                let alert = UIAlertController(title: "Trinity Books", message: "Failed to add '\(book.title)' to your cart", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
                    self.addToCart(book: book, completion: completion)
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completion()})
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func removeBook(book: Book, completion: @escaping () -> Void) {
        showLoading()
        manager.performRemoveBook(book) {
            self.hideLoading()
            switch $0 {
            case let .success(updatedBook):
                
                self.setBook(updatedBook)
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: BookDetailsNotification.bookRemoved.rawValue),
                                                             object: updatedBook,
                                                             userInfo: nil))
                completion()
            case let .failure(error):
                guard error != .invalidParameters else {
                    print("Book is not in the cart")
                    return
                }
                
                let alert = UIAlertController(title: "Trinity Books", message: "Failed to remove '\(book.title)' from your cart", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
                    self.removeBook(book: book, completion: completion)
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completion()})
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Controller
private extension BookDetailsViewController {
    @IBAction func actionAddToCart(_ sender: UIButton) {
        if !viewModel.inLibrary {
            addToCart(book: viewModel.book) {
                //let _ = self.navigationController?.popViewController(animated: true)
            }
        } else {
            removeBook(book: viewModel.book) {
                //let _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: - Presenter
extension BookDetailsViewController : Configurable {
    func configure(with dataSource: AnyBookViewModel) {
        navigationItem.title = dataSource.title
        tvDescription.text = dataSource.description
        lAuthor.text = dataSource.author
        
        let title = dataSource.inLibrary ? "Remove from Cart" : "Add to Cart"
        let color = dataSource.inLibrary ? Pallete.red : Pallete.main
        
        bCart.setTitle(title, for: .normal)
        bCart.setTitleColor(color, for: .normal)
        bCart.tintColor = color
        aiAddingBook.color = color
        
        guard let url = URL(string: dataSource.coverUri) else {
            print("Invalid url for cover : \(dataSource.coverUri)")
            return
        }
        aiLoadingCover.startAnimating()
        ivCover.af_setImage(withURLRequest: URLRequest(url: url), placeholderImage: #imageLiteral(resourceName: "logo"), runImageTransitionIfCached: true) {
            self.aiLoadingCover.stopAnimating()
            self.ivCover.image = $0.result.value
        }
    }
    
    fileprivate func showLoading() {
        aiAddingBook.startAnimating()
        bCart.isEnabled = false
    }
    
    fileprivate func hideLoading() {
        aiAddingBook.stopAnimating()
        bCart.isEnabled = true
    }
}
