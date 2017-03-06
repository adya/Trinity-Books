import UIKit

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
   
    fileprivate func showLoading() {
        aiAddingBook.startAnimating()
        bCart.isEnabled = false
    }
    
    fileprivate func hideLoading(success: Bool) {
        aiAddingBook.stopAnimating()
        if !success { bCart.isEnabled = true }
    }
    
}

// MARK: - Interactor
private extension BookDetailsViewController {
    func addToCart(book: Book, completion: @escaping () -> Void) {
        showLoading()
        manager.performAddBook(book) {
            switch $0 {
            case let .success(updatedBook):
                self.hideLoading(success: true)
                self.setBook(updatedBook)
                completion()
            case let .failure(error):
                guard error != .invalidParameters else {
                    print("Book is already in the cart")
                    return
                }
                
                self.hideLoading(success: false)
                
                let alert = UIAlertController(title: "Trinity Books", message: "Failed to load your cart", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
                    self.addToCart(book: book, completion: completion)
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completion()})
                self.present(alert, animated: true, completion: nil)
            }
        }
        completion()
    }
}

// MARK: - Controller
private extension BookDetailsViewController {
    @IBAction func actionAddToCart(_ sender: UIButton) {
        addToCart(book: viewModel.book) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - Presenter
extension BookDetailsViewController : Configurable {
    func configure(with dataSource: AnyBookViewModel) {
        navigationItem.title = dataSource.title
        tvDescription.text = dataSource.description
        lAuthor.text = dataSource.author
        bCart.isEnabled = !dataSource.inLibrary
        
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
}
