/**
 Represents common interface of the Response. Used intensively to handle array of different `RequestCall`'s.
 
 - Requires:    iOS  [2.0; 8.0)
 - Requires:    Swift 3+
 - Version:     2.1
 - Since:       10/30/2016
 - Author:      AdYa
 */
public protocol AnyResponse {
    
    /// Defines kind of data which response can handle
    /// - Note: Optional. (default: .JSON)
    static var kind : ResponseKind {get}
    
    /// Mandatory initializer to set a request related to this response.
    /// - Note: Initializer can fail if it could not handle response body.
    init?(request : Request, body : Any)
    
    /// Request related to the response.
    var request : Request {get}
}

/**
 Defines a response object.
 
 - Requires:    iOS  [2.0; 8.0)
 - Requires:    Swift 2+
 - Version:     2.1
 - Since:       10/30/2016
 - Author:      AdYa
 */
public protocol Response : AnyResponse {
    
    /// Type of the handled object.
    associatedtype ObjectType
    
    /// Contains response object.
    var value : ObjectType {get}
}

/**
 Defines what kind of data `Response` can handle
 
 - Requires:    iOS  [2.0; 8.0)
 - Requires:    Swift 2+
 - Version:     2.1
 - Since:       10/30/2016
 - Author:      AdYa
 */
public enum ResponseKind {
    
    /// Response handles JSON.
    case json
    
    /// Response handles NSData.
    case data
    
    /// Response handles String.
    case string
}

// MARK: - Response Defaults
public extension Response {
    
    public static var kind : ResponseKind {
        return .json
    }
    
    public var description: String {
        if let descr = self.value as? CustomStringConvertible {
            return "Value: \(descr)"
        } else {
            return "Value: \(String(describing: self.value))"
        } 
    }
}
