import UIKit

class BooksViewController: BaseBooksViewController {

    fileprivate enum Segues : String {
        case toDetails = "segDetails"
    }
    
    fileprivate let manager = try! Injector.inject(AnyBooksProvider.self)
    fileprivate let cartManager = try! Injector.inject(AnyCartManager.self)
    
    private var searchController : UISearchController!
    
    @IBOutlet weak fileprivate var tvBooks: UITableView!
    
    fileprivate var viewModel : AnyBooksViewModel!
    fileprivate var selectedBookCellIndex : IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = try! Injector.inject(AnyBooksViewModel.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedBook = selectedBookCellIndex { // when returning from details screen update selected book
            updateBookViewModel(at: selectedBook)
            self.selectedBookCellIndex = nil
        }
    }
    
    override func bookHasBeenAdded(_ book: Book) {
        guard let index = viewModel.books?.index(where: {
            $0.book == book
        }) else {
            print("Book wasn't found in viewModel.")
            return
        }
        updateBookViewModel(with: book, at: bookCellIndex(at: index))
    }
    
    override func bookHasBeenRemoved(_ book: Book) {
        guard let selectedBook = selectedBookCellIndex else {
            print("Selected index was not set")
            return
        }
        updateBookViewModel(with: book, at: selectedBook)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier, id == Segues.toDetails.rawValue, let controller = segue.destination as? BookDetailsViewController else {
            print("Unsupported segue")
            return
        }
        
        guard let index = selectedBookCellIndex.flatMap({bookIndex(at: $0)}),
            let book = viewModel?.books?[index].book else {
            print("Selection was not defined.")
            return
        }
        
        controller.setBook(book)
    }
    
    
}

// MARK: - Presenter?
private extension BooksViewController {
   
    /// Updates selected book.
    func updateBookViewModel(at indexPath : IndexPath) {
        let index = bookIndex(at: indexPath)
        guard let book = viewModel.books?[index].book else {
            return
        }
        updateBookViewModel(with: book, at: indexPath)
    }
    
    func updateBookViewModel(with book: Book, at indexPath : IndexPath) {
        let index = bookIndex(at: indexPath)
        viewModel.books?[index] = try! Injector.inject(AnyBookViewModel.self, with: book)
        tvBooks.reloadRows(at: [indexPath], with: .fade)
    }
    
    func hideBook(at indexPath: IndexPath) {
        let index = bookIndex(at: indexPath)
        viewModel.books?.remove(at: index)
        if hasBooks {
            tvBooks.deleteRows(at: [indexPath], with: .automatic)
        } else {
            tvBooks.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func reloadViewModel(with books: [Book]) {
        viewModel = try! Injector.inject(AnyBooksViewModel.self, with: books)
        tvBooks.reloadData()
    }
}

// MARK: - Interactor
private extension BooksViewController {
    func addToCart(at indexPath: IndexPath) {
        let index = bookIndex(at: indexPath)
        guard let book = viewModel.books?[index].book else {
            print("Invalid book")
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        cartManager.performAddBook(book) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch $0 {
            case let .success(updatedBook):
                self.updateBookViewModel(with: updatedBook, at: indexPath)
            case let .failure(error):
                guard error != .invalidParameters else {
                    print("Book is already in the cart")
                    return
                }
                let alert = UIAlertController(title: "Trinity Books", message: "Failed to load your cart", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
                    self.addToCart(at: indexPath)
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
            cartManager.performRemoveBook(book) { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.updateBookViewModel(at: indexPath)
            }
        } else {
            print("Failed to remove product")
        }
    }
    
    func serachBooks(term : String) {
        showLoading()
        manager.performBookSearch(term: term) {
            self.hideLoading()
            switch $0 {
            case let .success(books):
                self.reloadViewModel(with: books)
            case .failure:
                print("failed")
            }
        }
    }
}

// MARK: - TableView (Presenter & Controller)
extension BooksViewController : UITableViewDataSource, UITableViewDelegate {

    fileprivate var hasBooks : Bool {
        return viewModel.books?.count ?? 0 > 0
    }
    
    /// Returns an index of the book, considering additional loading cell.
    /// - Parameter indexPath: IndexPath of a book cell.
    fileprivate func bookIndex(at indexPath: IndexPath) -> Int {
        return viewModel.isLoading ? indexPath.row - 1 : indexPath.row
    }
    
    /// Returns indexPath of the book cell, considering additional loading cell.
    /// - Parameter index: Index of the viewModel entry.
    fileprivate func bookCellIndex(at index: Int) -> IndexPath {
        return IndexPath(row: index + (viewModel.isLoading ? 1 : 0), section: 0)
    }
    
    fileprivate func isBookCellIndex(at indexPath: IndexPath) -> Bool {
        return hasBooks && (!viewModel.isLoading || indexPath.row > 0)
    }
    
    fileprivate func isLoadingCellIndex(at indexPath: IndexPath) -> Bool {
        return viewModel.isLoading && indexPath.row == 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasBooks ? viewModel.books!.count + (viewModel.isLoading ? 1 : 0) : 1 // empty cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return hasBooks ? isBookCellIndex(at: indexPath) ? BookCell.height : LoadingCell.height : MessageCell.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoadingCellIndex(at: indexPath) {
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
        return isBookCellIndex(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBookCellIndex = indexPath
        performSegue(withIdentifier: Segues.toDetails.rawValue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Hide", handler: { (action, indexPath) in
            self.hideBook(at: indexPath)
        })
        delete.backgroundColor = UIColor.gray
        
        let index = bookIndex(at: indexPath)
        let inCart = viewModel.books?[index].inLibrary ?? false
        
        let toCart = UITableViewRowAction(style: .normal, title: inCart ? "Remove" : "Add to cart", handler: { (action, indexPath) in
            if inCart {
                self.removeBook(at: indexPath)
            } else {
                self.addToCart(at: indexPath)
            }
        })
        toCart.backgroundColor = inCart ? Pallete.red : Pallete.main
        
        return [delete, toCart]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isBookCellIndex(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {/* Stub to make cell editing working */}
}

// MARK: - Presenter
private extension BooksViewController {
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
