import UIKit

class CartViewController: UIViewController {

    fileprivate enum Segues : String {
        case toDetails = "segDetails"
    }
    
    fileprivate let manager = try! Injector.inject(AnyCartManager.self)
    
    fileprivate var viewModel : AnyBooksViewModel!
    fileprivate var selectedBook : Int?
    
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
            let book = viewModel?.books?[selectedBook].book else {
                print("Selection was not defined.")
                return
        }
        self.selectedBook = nil
        controller.setBook(book)
    }
    
    func setCart(_ cart: Cart) {
        viewModel = try! Injector.inject(AnyBooksViewModel.self, with: cart.books, for: self)
        tvBooks.reloadData()
    }
    
    func showLoading() {
        guard !viewModel.isLoading else {
            return
        }
        viewModel.isLoading = true
        let indexPath = [IndexPath(row: 0, section: 0)]
        if hasBooks {
            tvBooks.insertRows(at: indexPath, with: .top)
        } else {
            tvBooks.reloadRows(at: indexPath, with: .fade)
        }
    }
    
    func hideLoading() {
        guard viewModel.isLoading else {
            return
        }
        viewModel.isLoading = false
        let indexPath = [IndexPath(row: 0, section: 0)]
        if hasBooks {
            tvBooks.deleteRows(at: indexPath, with: .top)
        } else {
            tvBooks.reloadRows(at: indexPath, with: .fade)
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
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func removeBook(at indexPath: IndexPath) {
        let index = bookIndex(at: indexPath)
        if let book = viewModel.books?[index].book {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            manager.performRemoveBook(book) { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        } else {
            print("Failed to remove product")
        }
        viewModel.books?.remove(at: index)
        if hasBooks {
            tvBooks.deleteRows(at: [indexPath], with: .automatic)
        } else {
            tvBooks.reloadRows(at: [indexPath], with: .automatic)
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
    
    fileprivate func bookIndex(at indexPath: IndexPath) -> Int {
        return viewModel.isLoading ? indexPath.row - 1 : indexPath.row
    }
    
    fileprivate func isBookIndex(at indexPath: IndexPath) -> Bool {
        return hasBooks && !isLoadingIndex(at: indexPath)
    }
    
    fileprivate func isLoadingIndex(at indexPath: IndexPath) -> Bool {
        return viewModel.isLoading && indexPath.row == 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasBooks ? viewModel.books!.count + (viewModel.isLoading ? 1 : 0) : 1 // empty cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return hasBooks ? isBookIndex(at: indexPath) ? BookCell.height : LoadingCell.height : MessageCell.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoadingIndex(at: indexPath) {
            let cell = tableView.dequeueReusableCell(of: LoadingCell.self)
            cell.configure(with: viewModel.loadingMessage)
            return cell
        } else if hasBooks {
            let index = bookIndex(at: indexPath)
            
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
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return isBookIndex(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBook = bookIndex(at: indexPath)
        performSegue(withIdentifier: Segues.toDetails.rawValue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Remove", handler: { (action, indexPath) in
            self.removeBook(at: indexPath)
        })
        delete.backgroundColor = Pallete.red
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isBookIndex(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {/* Stub to make cell editing working */ }
}
