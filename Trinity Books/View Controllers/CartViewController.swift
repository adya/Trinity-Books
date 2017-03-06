import UIKit

class CartViewController: UIViewController {

    fileprivate enum Segues : String {
        case toDetails = "segDetails"
    }
    
    fileprivate let manager = try! Injector.inject(AnyCartManager.self)
    
    fileprivate var viewModel : AnyBooksViewModel!
    fileprivate var selectedBook : IndexPath? {
        didSet {
            if selectedBook != nil {
                performSegue(withIdentifier: Segues.toDetails.rawValue, sender: self)
            }
        }
    }
    @IBOutlet weak fileprivate var tvBooks: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = try! Injector.inject(AnyBooksViewModel.self, for: self)
        loadCart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier, id == Segues.toDetails.rawValue, let controller = segue.destination as? BookDetailsViewController else {
            print("Unsupported segue")
            return
        }
        
        guard let selectedBook = selectedBook,
            let book = viewModel?.books?[selectedBook.row].book else {
                print("Selection was not defined.")
                return
        }
        self.selectedBook = nil
        controller.setBook(book)
    }
    
    func setCart(_ cart: Cart) {
        viewModel = try! Injector.inject(AnyBooksViewModel.self, with: cart.books, for: self)
    }
    
    func showLoading() {
        viewModel.isLoading = true
        let indexPath = [IndexPath(row: 0, section: 0)]
        if hasBooks {
            tvBooks.insertRows(at: indexPath, with: .automatic)
        } else {
            tvBooks.reloadRows(at: indexPath, with: .automatic)
        }
    }
    
    func hideLoading() {
        viewModel.isLoading = false
        let indexPath = [IndexPath(row: 0, section: 0)]
        if hasBooks {
            tvBooks.deleteRows(at: indexPath, with: .automatic)
        } else {
            tvBooks.reloadRows(at: indexPath, with: .automatic)
        }
    }
}

// MARK: - Interactor
private extension CartViewController {
    
    func loadCart() {
        showLoading()
        manager.performLoadCart() {
            self.hideLoading()
            switch $0 {
            case let .success(cart):
                self.setCart(cart)
            case .failure:
                let alert = UIAlertController(title: "Trinity Books", message: "Failed to load your cart", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
                    self.loadCart()
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
                present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Controller
private extension CartViewController {
    @IBAction func actionRefresh(_ sender: UIButton) {
        loadCart()
    }

}

// MARK: - TableView
extension CartViewController : UITableViewDataSource, UITableViewDelegate {
    
    fileprivate var hasBooks : Bool {
        return viewModel.books?.count ?? 0 > 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasBooks ? viewModel.books!.count + (viewModel.isLoading ? 1 : 0) : 1 // empty cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return hasBooks ? !viewModel.isLoading ? BookCell.height : MessageCell.height : MessageCell.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.isLoading && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(of: LoadingCell.self)
            cell.configure(with: viewModel.loadingMessage)
            return cell
        } else if hasBooks {
            let index = viewModel.isLoading ? indexPath.row - 1 : indexPath.row
            
            let cell = tableView.dequeueReusableCell(of: BookCell.self)
            if let bookViewModel = viewModel.books?[index] {
                cell.configure(with: bookViewModel)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(of: MessageCell.self)
            cell.configure(with: viewModel.emptyMessage)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
