/** 
 Represents result of the request with associated responsed object.
 
 - Requires:    iOS  [2.0; 8.0)
 - Requires:    Swift 2+
 - Version:     2.1
 - Since:       10/30/2016
 - Author:      AdYa
 */
public enum ResponseResult <T: Any> {
    
    /// Response was successful and valid.
    /// - Parameter response: a response object.
    case success(response : T)
    
    /// Request failed with an error.
    /// - Parameter error: Occured error.
    case failure(error : RequestError)
}

/**
 Represents result of the request without any object.

- Requires:    iOS  [2.0; 8.0)
- Requires:    Swift 2+
- Version:     2.1
- Since:       10/30/2016
- Author:      AdYa
*/
public enum Result {
    
    /// Response was successful and valid.
    case success
    
    /// Request failed with an error.
    case failure(error : RequestError)
}

// MARK: - Conversion
public extension Result {
    public init(responseResult : AnyResponseResult) {
        switch responseResult {
        case .success: self = .success
        case .failure(let error): self = .failure(error: error)
        }
    }
}

public typealias AnyResponseResult = ResponseResult<AnyResponse>
