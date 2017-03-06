import UIKit

class MessageCell: UITableViewCell, TableViewElement, Configurable {

    static let height: CGFloat = 60

    @IBOutlet weak private var lMessage: UILabel!

    func configure(with dataSource: AnyMessageCellDataSource) {
        lMessage.text = dataSource.message
    }
}

protocol AnyMessageCellDataSource {
    var message : String {get}
}
