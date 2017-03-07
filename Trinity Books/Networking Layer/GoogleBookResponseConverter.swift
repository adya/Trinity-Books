class GoogleBooksResponseConverter: ResponseConverter<Book> {
    override func convert(_ dictionary: [String : AnyObject]) -> Book? {
        guard let id = dictionary[ItemKeys.id.rawValue] as? String,
        let volume = dictionary[ItemKeys.volume.rawValue] as? [String : AnyObject],
        let title = volume[VolumeKeys.title.rawValue] as? String,
        let subtitle = volume[VolumeKeys.subtitle.rawValue] as? String,
        let description = volume[VolumeKeys.description.rawValue] as? String,
        let authors = volume[VolumeKeys.authors.rawValue] as? [String],
        let images = volume[VolumeKeys.images.rawValue] as? [String : String]
        else {
            return nil
        }
        
        let cover = coverImage(from: images)
        let thumbnail = thumbnailImage(from: images)
        
        return Book(id: id,
                    title: title,
                    subtitle: subtitle,
                    authors: authors,
                    description: description,
                    coverUri: cover,
                    thumbnailUri: thumbnail,
                    inLibrary: false)
    }
    
    /// Defines priorities of available images to be used as Cover.
    private func coverImage(from images: [String : String]) -> String? {
        return images[ImageKeys.large.rawValue] ??
        images[ImageKeys.extra.rawValue] ??
        images[ImageKeys.medium.rawValue] ??
        images[ImageKeys.small.rawValue]
    }
    
    /// Defines priorities of available images to be used as Thumbnail.
    private func thumbnailImage(from images: [String : String]) -> String? {
        return images[ImageKeys.thumbnail.rawValue] ??
            images[ImageKeys.smallThumbnail.rawValue] ??
            images[ImageKeys.small.rawValue]
    }
}

private enum ItemKeys : String {
    
    case id = "id"
    case volume = "volumeInfo"
    
   
}

private enum VolumeKeys : String {
    case title = "title"
    case subtitle = "subtitle"
    case description = "description"
    case authors = "authors"
    case images = "imageLinks"
}

private enum ImageKeys : String {
    case extra = "extraLarge"
    case large = "large"
    case medium = "medium"
    case small = "small"
    case smallThumbnail = "smallThumbnail"
    case thumbnail = "thumbnail"
}

/*
 {
 "id": "GGae7FB3zoQC",
 "volumeInfo": {
 "title": "Lord of Misrule",
 "subtitle": "The Morganville Vampires",
 "authors": [
 "Rachel Caine"
 ],
 "description": "In the college town of Morganville, vampires and humans coexist in (relatively) bloodless harmony. Then comes Bishop, the master vampire who threatens to abolish all order, revive the forces of the evil dead, and let chaos rule. But Bishop isn’t the only threat. Violent black cyclone clouds hover, promising a storm of devastating proportions as student Claire Danvers and her friends prepare to defend Morganville against elements both natural and unnatural. Watch a Windows Media trailer for this book."
 }
 }
 */
