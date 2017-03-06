protocol AnyBookViewModel : AnyBookCellDataSource {
    var book : Book {get}
    
    var coverUri : String {get}
}
