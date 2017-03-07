/** 
 Defines set of handles error.
 
 - Requires:    iOS  [2.0; 8.0)
 - Requires:    Swift 2+
 - Version:     1.0
 - Since:       10/30/2016
 - Author:      AdYa
 */
public enum RequestError : Error {
    
    /// Error occured while remote service processing the request.
    case serverError
    
    /// Request couldn't reach destination.
    case networkError
    
    /// Given `Request` object is not valid to be sent.
    case invalidRequest
    
    /// Actual response has type different from specified `ResponseKind`. Therefore couldn't be handled by `Response`.
    case invalidResponseKind
    
    /// Remote service correctly processed `Request`, but responsed with an error.
    case failedRequest
    
    /// Remote service requires authorization, which either was not provided or was invalid.
    case authorizationError
}
