import UIKit

class BooksViewController: UIViewController {

    fileprivate var viewModel : AnyBooksViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = try! Injector.inject(AnyBooksViewModel.self)
    }
}

extension BooksViewController : UITableViewDataSource, UITableViewDelegate {

    private var hasBooks : Bool {
        return viewModel.books?.count ?? 0 > 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasBooks ? viewModel.books!.count : 1 // empty cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return hasBooks ? BookCell.height : MessageCell.height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if hasBooks, let bookViewModel = viewModel.books?[indexPath.row] {
            let cell = tableView.dequeueReusableCell(of: BookCell.self)
            cell.configure(with: bookViewModel)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(of: MessageCell.self)
            cell.configure(with: viewModel.empty)
            return cell
        }
    }
}

