/// TSTOOLS: Description... date: 09/06/16
/// Modified : 09/23/16 (added TSIdentifiable)

public protocol Configurable {
    associatedtype TSPresenterDataSource
    func configure(with dataSource : TSPresenterDataSource)
}

public protocol Stylable {
    associatedtype TSStyleSoruce
    func style(with styleSource : TSStyleSoruce)
}

public protocol IdentifiableView {
    static var identifier : String {get}
}

public extension IdentifiableView {
    static var identifier : String {
        return String(describing: self)
    }
}
