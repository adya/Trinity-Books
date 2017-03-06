struct Book : Identifiable {
    let id: Int
    let title : String
    let author : String
    let description : String
    let coverUri : String
    let thumbnailUri : String
    var inLibrary : Bool
}

extension Book : Archivable {
    init?(fromArchive archive: [String : AnyObject]) {
        guard let id = archive[Keys.id.rawValue] as? Int,
            let title = archive[Keys.title.rawValue] as? String,
        let author = archive[Keys.author.rawValue] as? String,
        let description = archive[Keys.description.rawValue] as? String,
        let coverUri = archive[Keys.coverUri.rawValue] as? String,
        let thumbnailUri = archive[Keys.thumbnailUri.rawValue] as? String,
        let inLibrary = archive[Keys.inLibrary.rawValue] as? Bool
        else {
                return nil
        }
        self.init(id: id,
                  title: title,
                  author: author,
                  description: description,
                  coverUri: coverUri,
                  thumbnailUri: thumbnailUri,
                  inLibrary: inLibrary)
    }
    
    func archived() -> [String : AnyObject] {
        return [
            Keys.id.rawValue : id as AnyObject,
            Keys.title.rawValue : title as AnyObject,
            Keys.author.rawValue : author as AnyObject,
            Keys.description.rawValue : description as AnyObject,
            Keys.coverUri.rawValue : coverUri as AnyObject,
            Keys.thumbnailUri.rawValue : thumbnailUri as AnyObject,
            Keys.inLibrary.rawValue : inLibrary as AnyObject
        ]
    }
}

private enum Keys : String {
    case id = "kId"
    case title = "kTitle"
    case author = "kAuthor"
    case description = "kDescription"
    case coverUri = "kCoverUri"
    case thumbnailUri = "kThumbnailUri"
    case inLibrary = "kInLibrary"
}
