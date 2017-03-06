import UIKit

class BooksViewController: BaseBooksViewController {

    fileprivate enum Segues : String {
        case toDetails = "segDetails"
    }
    
    fileprivate let manager = try! Injector.inject(AnyBooksProvider.self)
    fileprivate let libraryManager = try! Injector.inject(AnyLibraryManager.self)
    
    @IBOutlet weak fileprivate var searchBar: UISearchBar!
    @IBOutlet weak fileprivate var tvBooks: UITableView!
    
    fileprivate var viewModel : AnyBooksViewModel!
    fileprivate var selectedBookCellIndex : IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        tvBooks.rowHeight = UITableViewAutomaticDimension
        viewModel = try! Injector.inject(AnyBooksViewModel.self)
    }
    
    private func findBook(_ book: Book) -> Int? {
        return viewModel.books?.index {
            $0.book == book
        }
    }
    
    /// Updates list of books when it's changed
    override func bookHasBeenAdded(_ book: Book) {
        guard let index = findBook(book) else {
            print("\(type(of: self)): Book wasn't found in viewModel.")
            return
        }
        updateBookViewModel(with: book, at: bookCellIndex(at: index))
    }
    
    /// Updates list of books when it's changed
    override func bookHasBeenRemoved(_ book: Book) {
        guard let index = findBook(book) else {
            print("\(type(of: self)): Book wasn't found in viewModel.")
            return
        }
        updateBookViewModel(with: book, at: bookCellIndex(at: index))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier, id == Segues.toDetails.rawValue, let controller = segue.destination as? BookDetailsViewController else {
            print("\(type(of: self)): Unsupported segue")
            return
        }
        
        guard let index = selectedBookCellIndex.flatMap({bookIndex(at: $0)}),
            let book = viewModel?.books?[index].book else {
            print("\(type(of: self)): Selection was not defined.")
            return
        }
        selectedBookCellIndex = nil
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
    
    func reloadViewModel(with books: [Book]? = nil) {
        if let books = books {
            viewModel = try! Injector.inject(AnyBooksViewModel.self, with: books)
        } else {
            viewModel = try! Injector.inject(AnyBooksViewModel.self)
        }
        tvBooks.reloadData()
    }
}

// MARK: - Interactor
private extension BooksViewController {
    func addToLibrary(at indexPath: IndexPath) {
        let index = bookIndex(at: indexPath)
        guard let book = viewModel.books?[index].book else {
            print("\(type(of: self)): Invalid book")
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        libraryManager.performAddBook(book) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            switch $0 {
//            case let .success(updatedBook):
                // updates handled via notifications.
                // self.updateBookViewModel(with: updatedBook, at: indexPath)
            if case let .failure(error) = $0 {
                guard error != .invalidParameters else {
                    print("\(type(of: self)): Book is already in the library")
                    return
                }
                let alert = UIAlertController(title: "Trinity Books", message: "Failed to load your library", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
                    self.addToLibrary(at: indexPath)
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
            libraryManager.performRemoveBook(book) { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                // updates handled via notifications.
                // self.updateBookViewModel(at: indexPath)
            }
        } else {
            print("\(type(of: self)): Failed to remove product")
        }
    }
    
    func searchBooks(term : String) {
        showLoading()
        manager.performBookSearch(term: term) {
            self.hideLoading()
            switch $0 {
            case let .success(books):
                self.reloadViewModel(with: books)
            case .failure:
                print("\(type(of: self)): failed")
            }
        }
    }
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

// MARK: Search
extension BooksViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        guard let term = searchBar.text else {
            print("\(type(of: self)): Empty string")
            return
        }
        searchBooks(term: term)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        reloadViewModel()
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
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
        let inLibrary = viewModel.books?[index].inLibrary ?? false
        
        let toLibrary = UITableViewRowAction(style: .normal, title: inLibrary ? "Remove from Library" : "Add to Library", handler: { (action, indexPath) in
            if inLibrary {
                self.removeBook(at: indexPath)
            } else {
                self.addToLibrary(at: indexPath)
            }
        })
        toLibrary.backgroundColor = inLibrary ? Pallete.red : Pallete.main
        
        return [delete, toLibrary]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isBookCellIndex(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {/* Stub to make cell editing working */}
}
