import UIKit

class LoadingCell: MessageCell {

    @IBOutlet weak private var aiLoading: UIActivityIndicatorView!
    
    override func configure(with dataSource: AnyMessageCellDataSource) {
        super.configure(with: dataSource)
        aiLoading.startAnimating()
    }
}
