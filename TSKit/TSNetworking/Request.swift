/** 
 Defines request properties required to perform request call.
 
 - Requires:    iOS  [2.0; 8.0)
 - Requires:    Swift 2+
 - Version:     2.1
 - Since:       10/30/2016
 - Author:      AdYa
 */
public protocol Request : CustomStringConvertible {
    
    /// HTTP Method of the request.
    var method : RequestMethod {get}
    
    /** Encoding method used to encode request parameters.
     - Note: Default = determined by HTTP Method.
     * .GET, .DELETE -> .URL
     * .POST, .PUT, .PATCH -> JSON
     */
    var encoding : RequestEncoding {get}
    
    /// Base url which will be used insted of default one from `RequestManager` configuration.
    /// - Note: Default = nil.
    var baseUrl : String? {get}
    
    /// Url part for request
    var url : String {get}
    
    /// Parameters of the request.
    var parameters : [String : AnyObject]? {get}
    
    /// Overriden encoding methods for specified parameters.
    /// Allows to encode several params in a different way.
    /// - Note: Default = nil.
    var parametersEncodings : [String : RequestEncoding]? {get}
    
    /// Any custom headers that must be attached to that request.
    /// - Note: Default = nil.
    var headers : [String : String]? {get}
}

/** 
 Defines supported HTTP Methods.
 
 - Requires:    iOS  [2.0; 8.0)
 - Requires:    Swift 2+
 - Version:     2.1
 - Since:       10/30/2016
 - Author:      AdYa
 */
public enum RequestMethod {
    case get
    case post
    case delete
    case put
    case patch
}

/** 
 Defines how request parameters should be encoded.
 
 - Requires:    iOS  [2.0; 8.0)
 - Requires:    Swift 2+
 - Version:     2.1
 - Since:       10/30/2016
 - Author:      AdYa
 */
public enum RequestEncoding {
    
    /// Encoded as url query.
    case url
    
    /// Encoded as json and inserted into request body.
    case json
    
    /// Encoded as parts of multipart-form data.
    case formData
}

// MARK: - Defaults
public extension Request {
    
    public var baseUrl : String? {
        return nil
    }
    
    public var headers : [String : String]? {
        return nil
    }
    
    public var encoding : RequestEncoding {
        switch self.method {
        case .get, .delete: return .url
        case .post, .put, .patch: return .json
        }
    }
    
    var parametersEncodings : [String : RequestEncoding]? {
        return nil
    }
    
    var description: String {
        var descr = "\(self.method) '"
        if let baseUrl = self.baseUrl {
            descr += "\(baseUrl)/"
        }
        descr += "\(self.url)'"
        if let headers = self.headers {
            descr += "\nHeaders:\n\(headers)"
        }
        if let params = self.parameters {
            descr += "\nParameters:\n\(params)"
        }
        return descr
    }
}

