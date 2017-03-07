struct Book : Hashable {
    let id: String
    let title : String
    let subtitle : String?
    let authors : [String]
    let description : String
    let coverUri : String?
    let thumbnailUri : String?
    var inLibrary : Bool
    
    var hashValue: Int {
        return id.hashValue
    }
}

func == (first : Book, second : Book) -> Bool {
    return first.hashValue == second.hashValue
}

extension Book : Archivable {
    init?(fromArchive archive: [String : AnyObject]) {
        guard let id = archive[Keys.id.rawValue] as? String,
            let title = archive[Keys.title.rawValue] as? String,
        let authors = archive[Keys.authors.rawValue] as? [String],
        let description = archive[Keys.description.rawValue] as? String,
        let inLibrary = archive[Keys.inLibrary.rawValue] as? Bool
        else {
                return nil
        }
        let subtitle = archive[Keys.subtitle.rawValue] as? String
        let coverUri = archive[Keys.coverUri.rawValue] as? String
        let thumbnailUri = archive[Keys.thumbnailUri.rawValue] as? String
        
        self.init(id: id,
                  title: title,
                  subtitle: subtitle,
                  authors: authors,
                  description: description,
                  coverUri: coverUri,
                  thumbnailUri: thumbnailUri,
                  inLibrary: inLibrary)
    }
    
    func archived() -> [String : AnyObject] {
        var archive : [String : Any] = [
            Keys.id.rawValue : id,
            Keys.title.rawValue : title,
            Keys.authors.rawValue : authors,
            Keys.description.rawValue : description,
            Keys.inLibrary.rawValue : inLibrary
        ]
        archive[Keys.subtitle.rawValue] = subtitle
        archive[Keys.thumbnailUri.rawValue] = thumbnailUri
        archive[Keys.coverUri.rawValue] = coverUri
        return archive as [String : AnyObject]
    }
}

private enum Keys : String {
    case id = "kId"
    case title = "kTitle"
    case subtitle = "kSubtitle"
    case authors = "kAuthors"
    case description = "kDescription"
    case coverUri = "kCoverUri"
    case thumbnailUri = "kThumbnailUri"
    case inLibrary = "kInLibrary"
}
