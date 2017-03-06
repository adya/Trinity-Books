import UIKit

class BooksViewController: UIViewController {

    fileprivate enum Segues : String {
        case toDetails = "segDetails"
    }
    
    private var searchController : UISearchController!
    
    fileprivate var viewModel : AnyBooksViewModel!
    fileprivate var selectedBook : IndexPath? {
        didSet {
            if selectedBook != nil {
                performSegue(withIdentifier: Segues.toDetails.rawValue, sender: self)
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = try! Injector.inject(AnyBooksViewModel.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedBook = selectedBook { // when returning from details screen update selected book
            updateBook(selectedBook)
            self.selectedBook = nil
        }
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
        
        controller.setBook(book)
    }
    
    fileprivate func updateBook(_ indexPath : IndexPath) {
        
    }
}

// MARK: - TableView
extension BooksViewController : UITableViewDataSource, UITableViewDelegate {

    private var hasBooks : Bool {
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
