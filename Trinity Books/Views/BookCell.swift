import UIKit

class BookCell: UITableViewCell, TableViewElement, Configurable {

    static let height: CGFloat = 120

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with dataSource: AnyBookCellDataSource) {

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


protocol AnyBookCellDataSource {
    var title : String {get}
    var coverUri : String {get}
    var author : String {get}

}
