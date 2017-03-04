import UIKit

class MessageCell: UITableViewCell, TableViewElement, Configurable {

    static let height: CGFloat = 60

    @IBOutlet weak private var lMessage: UILabel!

    func configure(with dataSource: AnyMessageCellDataSource) {
        lMessage.text = dataSource.message
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

protocol AnyMessageCellDataSource {
    var message : String {get}
}
