import UIKit

class BookDetailsViewController: UIViewController {
    
   // let manager = try! Injector.inject(AnyCartManager.self)
    
    func setBook(_ book : Book) {
        viewModel = try! Injector.inject(AnyBookViewModel.self, with: book)
    }
    
    fileprivate var viewModel : AnyBookViewModel!
    
    @IBOutlet weak fileprivate var bCart: UIButton!
    @IBOutlet weak fileprivate var tvDescription: UITextView!
    @IBOutlet weak fileprivate var ivCover: UIImageView!
    @IBOutlet weak fileprivate var aiLoadingCover: UIActivityIndicatorView!
    @IBOutlet weak fileprivate var lAuthor: UILabel!
    
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
    func addToCart(book: Book, completion: (Bool) -> Void) {
        completion(true)
    }
}

// MARK: - Controller
private extension BookDetailsViewController {
    @IBAction func actionAddToCart(_ sender: UIButton) {
        addToCart(book: viewModel.book) { _ in
            navigationController?.popViewController(animated: true)
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
