import UIKit
import Alamofire
import AlamofireImage

class BookCell: UITableViewCell, TableViewElement, Configurable {

    static let height: CGFloat = 120

    @IBOutlet weak private var lTitle: UILabel!
    @IBOutlet weak private var lAuthor: UILabel!
    @IBOutlet weak private var lDescription: UILabel!
    @IBOutlet weak private var ivCover: UIImageView!
    @IBOutlet weak private var aiLoadingCover: UIActivityIndicatorView!
    
    func configure(with dataSource: AnyBookCellDataSource) {
        lTitle.text = dataSource.title
        lAuthor.text = dataSource.author
        lDescription.text = dataSource.description
        
        accessoryType = dataSource.inLibrary ? .checkmark : .none
        
        guard let url = URL(string: dataSource.thumbnailUri) else {
            print("Invalid url for cover : \(dataSource.thumbnailUri)")
            return
        }
        aiLoadingCover.startAnimating()
        ivCover.af_setImage(withURLRequest: URLRequest(url: url), placeholderImage: #imageLiteral(resourceName: "logo"), runImageTransitionIfCached: true) {
            self.aiLoadingCover.stopAnimating()
            self.ivCover.image = $0.result.value
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        UIView.animate(withDuration: animated ? 0.7 : 0.0) {
            self.contentView.backgroundColor = selected ? Pallete.main : UIColor.white
            self.tintColor = selected ? UIColor.white : Pallete.main
            self.lTitle.textColor = selected ? UIColor.white : UIColor.darkText
            self.lAuthor.textColor = selected ? UIColor.white : UIColor.darkGray
            self.lDescription.textColor = selected ? UIColor.white : UIColor.darkText
            self.aiLoadingCover.color = selected ? UIColor.white : Pallete.main
        }
    }

}

protocol AnyBookCellDataSource {
    var title : String {get}
    var thumbnailUri : String {get}
    var author : String {get}
    var description : String {get}
    var inLibrary : Bool {get}
}
