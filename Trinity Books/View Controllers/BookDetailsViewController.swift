import UIKit

class BookDetailsViewController: UIViewController {
    
    let manager = try! Injector.inject(AnyLibraryManager.self)
    
    func setBook(_ book : Book) {
        viewModel = try! Injector.inject(AnyBookViewModel.self, with: book)
        if isViewLoaded {
            configure(with: viewModel)
        }
    }
    
    fileprivate var viewModel : AnyBookViewModel!
    
    @IBOutlet weak fileprivate var bLibrary: UIButton!
    @IBOutlet weak fileprivate var lDescription: UILabel!
    @IBOutlet weak fileprivate var ivCover: UIImageView!
    @IBOutlet weak fileprivate var aiLoadingCover: UIActivityIndicatorView!
    @IBOutlet weak fileprivate var lTitle: UILabel!
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
    func addToLibrary(book: Book, completion: @escaping () -> Void) {
        showLoading()
        manager.performAddBook(book) {
            self.hideLoading()
            switch $0 {
            case let .success(updatedBook):
                self.setBook(updatedBook)
                completion()
            case let .failure(error):
                guard error != .invalidParameters else {
                    print("\(type(of: self)): Book is already in the library")
                    return
                }
                
                let alert = UIAlertController(title: "Trinity Books", message: "Failed to add '\(book.title)' to your library", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
                    self.addToLibrary(book: book, completion: completion)
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
                completion()
            case let .failure(error):
                guard error != .invalidParameters else {
                    print("\(type(of: self)): Book is not in the library")
                    return
                }
                
                let alert = UIAlertController(title: "Trinity Books", message: "Failed to remove '\(book.title)' from your library", preferredStyle: .alert)
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
    @IBAction func actionAddToLibrary(_ sender: UIButton) {
        if !viewModel.inLibrary {
            addToLibrary(book: viewModel.book) {
                //let _ = self.navigationController?.popViewController(animated: true)
            }
        } else {
            removeBook(book: viewModel.book) {
                //let _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Presenter
extension BookDetailsViewController : Configurable {
    func configure(with dataSource: AnyBookViewModel) {
        lTitle.text = dataSource.title
        lDescription.text = dataSource.description
        lAuthor.text = dataSource.author
        
        let title = dataSource.inLibrary ? "Remove from Library" : "Add to Library"
        let color = dataSource.inLibrary ? Pallete.red : Pallete.main
        
        bLibrary.setTitle(title, for: .normal)
        bLibrary.backgroundColor = color
        aiAddingBook.color = color
        
        guard let url = URL(string: dataSource.coverUri) else {
            print("\(type(of: self)): Invalid url for cover : \(dataSource.coverUri)")
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
        bLibrary.isEnabled = false
        bLibrary.backgroundColor = UIColor.lightGray
    }
    
    fileprivate func hideLoading() {
        aiAddingBook.stopAnimating()
        bLibrary.isEnabled = true
        bLibrary.backgroundColor = viewModel.inLibrary ? Pallete.red : Pallete.main
    }
}
