/// TSTOOLS: 10/25/16.
open class ResponseConverter <T> where T : Any {
    open func convert(_ dictionary : [String : AnyObject]) -> T? {return nil}
    
    open func log(_ entity : AnyObject) {
        print("\(type(of: self)): Failed to parse: \n \(entity)")
    }
    
    public init() {}
}

open class RequestConverter <T> where T : Any {
    open func convert(_ model : T) -> [String : AnyObject]? { return nil }
    public init() {}
}
