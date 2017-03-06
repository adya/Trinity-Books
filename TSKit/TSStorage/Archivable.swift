/// Defines methods for archiving and unarchiving objects into/from dictionary.
/// - Date: 01/15/17
protocol Archivable {
    func archived() -> [String : AnyObject]
    init?(fromArchive : [String : AnyObject])
}