struct DummyBookViewModel : AnyBookViewModel {
    var book: Book {
        return Book(id: "1",
                    title: title,
                    subtitle: nil,
                    authors: [author],
                    description: description,
                    coverUri: coverUri,
                    thumbnailUri: thumbnailUri,
                    inLibrary: inLibrary)
    }

    let title: String = "The Lord of the Rings"
    
    let author: String = "John Ronald Reuel Tolkien"
   
    let coverUri: String? = "http://cdn.collider.com/wp-content/uploads/2016/07/the-lord-of-the-rings-book-cover.jpg"
    
    let thumbnailUri: String? = "http://cdn.collider.com/wp-content/uploads/2016/07/the-lord-of-the-rings-book-cover.jpg"
   
    let description: String = "The Lord of the Rings is an epic high fantasy trilogy written by English philologist and University of Oxford professor J.R.R. Tolkien. The story began as a sequel to Tolkien's earlier, less complex children's fantasy novel 'The Hobbit' (1937), but eventually developed into a much larger work which formed the basis for the extended Middle-Earth Universe. It was written in stages between 1937 and 1949, much of it during World War II. It is the third best-selling novel ever written, with over 150 million copies sold."
    
    let inLibrary: Bool = [true, false].random
}
