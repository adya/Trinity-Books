/**
 RequestManager is part of TSNetworking layer. It provides a way to do request calls defined by Request objects.
 
 **Key features:**
 1. It is designed to be used directly without any sublasses.
 2. Highly configurable via configuration object.
 3. Sync multiple requests.
 4. Simple and obvious way to create request calls.
 
 - Requires:    iOS  [2.0; 8.0)
 - Requires:    Swift 2+
 - Version:     2.1
 - Since:       10/30/2016
 - Author:      AdYa
 */
public protocol RequestManager {
    
    /// Mandatory initializer with configuration object to set default properties.
    /// - Parameter configuration: An object containing custom properties.
    init(configuration : RequestManagerConfiguration)
    
    /**
     Executes a request call.
     - Parameter requestCalls: Request calls to be executed.
     - Parameter option: Defines advanced behavior of the `RequestManager`.
     - Parameter completion: Completion closure to be called after all requests completed.
     */
    func request(_ requestCalls : [AnyRequestCall], option : ExecutionOption,  completion : RequestCompletion?)
    
    /**
     Executes a request call.
     - Parameter requestCall: Request call to be executed.
     - Parameter completion: Completion closure to be called after request completed.
     */
    func request(_ requestCall : AnyRequestCall, completion : RequestCompletion?)
}


public typealias RequestCompletion = (Result) -> Void

/// Defines advanced behavior of the `RequestManager` when dealing with multiple requests.
public enum ExecutionOption {
    
    /// Indicates that `RequestManager` should execute each request call synchronously.
    /// - Parameter ignoreFailures: Indicates whether the manager should abort when any error occured or continue execution.
    case executeSynchronously(ignoreFailures : Bool)
    
    /// Indicates that `RequestManager` should execute all request calls asynchronously.
    case executeAsynchronously
}

/// Defines configurable properties of `RequestManager`
public protocol RequestManagerConfiguration {
    
    /// Any default headers which must be attached to each request
    var headers : [String : String]? {get}
    
    /// Base url used for each request, unless the last one will explicitly override it.
    var baseUrl : String {get}
    
    /// Default timeout for each request.
    var timeout : Int {get}
}


public extension RequestManager {
    public func request(_ requestCalls : [AnyRequestCall], completion: RequestCompletion?) {
        self.request(requestCalls, option: .executeAsynchronously, completion: completion)
    }
    
    public func request(_ requestCalls : [AnyRequestCall]) {
        self.request(requestCalls, completion: nil)
    }
    
    public func request(_ requestCall : AnyRequestCall) {
        self.request(requestCall, completion: nil)
    }
}

public extension RequestManagerConfiguration {
    public var headers : [String : String]? {
        return nil
    }
    
    public var timeout : Int {
        return 30
    }
}
