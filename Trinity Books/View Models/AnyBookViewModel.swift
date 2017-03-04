protocol AnyBookViewModel : AnyBookCellDataSource {
    var book : Book {get}
    
    var description : String {get}
}
