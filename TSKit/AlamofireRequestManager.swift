import Alamofire

/**
 RequestManager is part of TSNetworking layer. It provides a way to do request calls defined by Request objects.
 Key features:
 1. It is designed to be used directly without any sublasses.
 2. Highly configurable via configuration object.
 3. Sync multiple requests.
 4. Simple and obvious way to create request calls.
 
 - Requires:   iOS  [2.0; 8.0)
 - Requires:   
 * TSNetworking framework
 * TSUtils
 
 - Version:    2.0
 - Since:      10/26/2016
 - Author:     AdYa
 */
public class AlamofireRequestManager : RequestManager {
    
    fileprivate let manager : Alamofire.SessionManager
    fileprivate var baseUrl : String?
    fileprivate var defaultHeaders : [String : String]?
    
    public func request(_ requestCall : AnyRequestCall, completion : RequestCompletion? = nil) {
        let request = requestCall.request
        let compoundCompletion : AnyResponseResultCompletion = {
            requestCall.completion?($0)
            completion?(Result(responseResult: $0))
        }
        let type = requestCall.responseType
        var aRequest : Alamofire.DataRequest?
        if let multipartRequest = request as? MultipartRequest {
            self.createMultipartRequest(multipartRequest, responseType: type, completion: compoundCompletion) {
                aRequest = $0//.validate()
                self.executeRequest(aRequest, withRequest: request, type: type, completion: compoundCompletion)
            }
        } else {
            aRequest = self.createRegularRequest(request, responseType : type, completion: compoundCompletion)//?.validate()
            self.executeRequest(aRequest, withRequest: request, type: type, completion: compoundCompletion)
        }
        
    }
    
    public func request(_ requestCalls : [AnyRequestCall], option : ExecutionOption, completion : ((Result) -> Void)? = nil) {
        switch option {
        case .executeAsynchronously:
            self.asyncRequest(requestCalls, completion: completion)
        case .executeSynchronously(let ignoreFailures):
            self.syncRequest(requestCalls, ignoreFailures: ignoreFailures, completion: completion)
        }
    }
    
    private func executeRequest(_ aRequest : Alamofire.DataRequest?, withRequest request: Request, type : AnyResponse.Type, completion: @escaping AnyResponseResultCompletion) {
        guard let aRequest = aRequest else {
            print("\(type(of: self)): Failed to execute request: \(request)")
            completion(.failure(error: .invalidRequest))
            return
        }
        if let baseUrl = request.baseUrl ?? self.baseUrl {
            print("\(type(of: self)): Request resolved to: \(baseUrl)")
        } else {
            print("\(type(of: self)): Warning: base URL wasn't defined for request\n\(request.description)")
            
        }
        print("\(type(of: self)): Executing request: \(request)")
        let _ = self.appendResponse(aRequest, request: request, type: type, completion: completion)
    }
    
    public required init(configuration: RequestManagerConfiguration) {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = Double(configuration.timeout)
        self.manager = Alamofire.SessionManager(configuration: sessionConfiguration)
        self.baseUrl = configuration.baseUrl
        self.defaultHeaders = configuration.headers
    }
    
    private var isReady : Bool {
        return self.baseUrl != nil
    }
    
    
    
}

// MARK: - Multiple requests.
private extension AlamofireRequestManager {
    func syncRequest(_ requestCalls : [AnyRequestCall], ignoreFailures : Bool, lastResult : Result? = nil, completion : ((Result) -> Void)?) {
        var calls = requestCalls
        guard let call = calls.first else {
            guard let result = lastResult else {
                completion?(.failure(error: .invalidRequest))
                return
            }
            completion?(result)
            return
        }
        self.request(call) { result in
            if ignoreFailures {
                calls.removeFirst()
                self.syncRequest(calls, ignoreFailures: ignoreFailures, lastResult: nil, completion: completion)
                
            } else if case .success = result {
                calls.removeFirst()
                self.syncRequest(calls, ignoreFailures: ignoreFailures, lastResult: .success, completion: completion)
            } else if case let .failure(error) = result{
                completion?(.failure(error: error))
            }
        }
    }
    
    func asyncRequest(_ requestCalls : [AnyRequestCall], completion : ((Result) -> Void)?) {
        let group = DispatchGroup()
        var response : Result? = nil
        requestCalls.forEach {
            group.enter()
            self.request($0) { res in
                switch res {
                case .success: response = .success
                case let .failure(error): response = .failure(error: error)
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            if let response = response {
                completion?(response)
            } else {
                completion?(.failure(error: .failedRequest))
            }
        }
    }
}

// MARK: - Constructing request properties.
private extension AlamofireRequestManager {
    
    func constructUrl(withRequest request: Request) -> String? {
        guard let baseUrl = (request.baseUrl ?? self.baseUrl) else {
            print("\(type(of: self)): Neither default baseUrl nor request's baseUrl had been specified.")
            return nil
        }
        
        return "\(baseUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/\(request.url)"
    }
    
    func constructHeaders(withRequest request : Request) -> [String : String]? {
        var headers = self.defaultHeaders
        if let customHeaders = request.headers {
            if headers == nil {
                headers = customHeaders
            } else if headers != nil {
                headers! += customHeaders
            }
        }
        return headers
    }
    
}

// MARK: - Constructing regular Alamofire request
private extension AlamofireRequestManager {
    func createRegularRequest(_ request : Request, responseType type: AnyResponse.Type, completion : AnyResponseResultCompletion) -> Alamofire.DataRequest? {
        guard let url = self.constructUrl(withRequest: request) else {
            completion(.failure(error:.invalidRequest))
            return nil
        }
        let method = HTTPMethod(method: request.method)
        let encoding = from(encoding: request.encoding)
        let headers = self.constructHeaders(withRequest: request)
        return self.manager.request(url, method: method, parameters: request.parameters, encoding: encoding, headers: headers)
    }
    
    private func from(encoding : RequestEncoding) -> Alamofire.ParameterEncoding {
        switch encoding {
        case .json: return JSONEncoding.default
        case .url: return URLEncoding.default
        case .formData: return URLEncoding.default
        }
    }

}

// MARK: - Constructing multipart Alamofire request.
private extension AlamofireRequestManager {
    
    func createMultipartRequest(_ request : MultipartRequest, responseType type: AnyResponse.Type, completion : @escaping AnyResponseResultCompletion, creationCompletion : @escaping (_ createdRequest : Alamofire.DataRequest) -> Void) {
        guard var url = self.constructUrl(withRequest: request) else {
            completion(.failure(error:.invalidRequest))
            return
        }
        let method = HTTPMethod(method: request.method)
        let headers = self.constructHeaders(withRequest: request)
        var urlParams : [String : AnyObject]?
        var dataParams : [String : AnyObject]? = request.parameters // by default all parameters are dataParams
        if let params = request.parameters {
            urlParams = params.filter {
                if let customEncoding = request.parametersEncodings?[$0.0], customEncoding == RequestEncoding.url {
                    return true
                }
                return false
            }
            if let urlParams = urlParams {
                urlParams.forEach{
                    url = self.encodeURLParam($0.1, withName: $0.0, inURL: url)
                }
                dataParams = params.filter { name, _ in
                    return !urlParams.contains { name == $0.0 }
                }
            }            
            print("\(type(of: self)): Encoded params into url: \(url)\n")
        }
        print("\(type(of: self)): Encoding data for multipart...")
        self.manager.upload(multipartFormData: { formData in
            if let files = request.files, !files.isEmpty {
                print("\(type(of: self)): Appending \(files.count) in-memory files...\n")
                files.forEach {
                    print("\(type(of: self)): Appending file \($0)...\n")
                    
                    formData.append($0.value, withName: $0.name, fileName: $0.fileName, mimeType: $0.mimeType)
                }
                
            }
            if let files = request.filePaths, !files.isEmpty {
                print("\(type(of: self)): Appending \(files.count) files from storage...\n")
                files.forEach{
                    print("\(type(of: self)): Appending file \($0)...\n")
                    formData.append($0.value, withName: $0.name)
                }
                
            }
            
            if let dataParams = dataParams {
                dataParams.forEach {
                    print("\(type(of: self)): Encoding parameter '\($0.0)'...")
                    self.appendParam($0.1, withName: $0.0, toFormData: formData, usingEncoding: request.parametersEncoding)
                }
            }
        },to: url, method: method, headers: headers
            , encodingCompletion: { encodingResult in
                switch encodingResult {
                case let .success(aRequest, _, _):
                    creationCompletion(aRequest)
                case .failure(let error):
                    print("\(type(of: self)): Failed to encode data with error: \(error).")
                    completion(.failure(error: .invalidRequest))
                }
        })
        
    }
    
    func createParameterComponent(_ param : AnyObject, withName name : String) -> [(String, String)] {
        var comps = [(String, String)]()
        if let array = param as? [AnyObject] {
            array.forEach {
                comps += self.createParameterComponent($0, withName: "\(name)[]")
            }
        } else if let dictionary = param as? [String : AnyObject] {
            dictionary.forEach { key, value in
                comps += self.createParameterComponent(value, withName: "\(name)[\(key)]")
            }
        } else {
            comps.append((name, "\(param)"))
        }
        return comps
    }
    
    
    func encodeURLParam(_ param : AnyObject, withName name : String, inURL url: String) -> String {
        let comps = self.createParameterComponent(param, withName: name).map {"\($0)=\($1)"}
        return "\(url)?\(comps.joined(separator: "&"))"
    }
    
    /// Appends param to the form data.
    func appendParam(_ param : AnyObject, withName name : String, toFormData formData : MultipartFormData, usingEncoding encoding: UInt) {
        let comps = self.createParameterComponent(param, withName: name)
        comps.forEach {
            guard let data = $0.1.data(using: String.Encoding(rawValue: encoding)) else {
                print("\(type(of: self)): Failed to encode parameter '\($0.0)'")
                return
            }
            formData.append(data, withName: $0.0)
        }
    }
}

// MARK: - Constructing Alamofire response.
private extension AlamofireRequestManager {
    
    func appendResponse(_ aRequest : Alamofire.DataRequest, request : Request, type : AnyResponse.Type, completion: @escaping AnyResponseResultCompletion) -> Alamofire.DataRequest {
        switch type.kind {
        case .json: return aRequest.responseJSON { res in
            if let error = res.result.error {
                print("\(type(of: self)): Internal error while sending request:\n\(error)")
                completion(.failure(error:.networkError))
            } else if let json = res.result.value {
                print("\(type(of: self)): Received JSON:\n\(json).")
                if let response = type.init(request: request, body: json) {
                    completion(.success(response: response))
                }
                else {
                    print("\(type(of: self)): Specified response type couldn't handle '\(type.kind)'. Response '\(type)' has '\(type.kind)'.")
                    completion(.failure(error:.invalidResponseKind))
                }
            } else {
                print("\(type(of: self)): Couldn't get any response.")
                completion(.failure(error: .failedRequest))
            }
            }
        case .data: return aRequest.responseData {res in
            if let error = res.result.error {
                print("\(type(of: self)): Internal error while sending request:\n\(error)")
                completion(.failure(error:.networkError))
            } else if let data = res.result.value {
                print("\(type(of: self)): Received \(data.dataSize) of data.")
                if let response = type.init(request: request, body: data) {
                    completion(.success(response: response))
                }
                else {
                    print("\(type(of: self)): Specified response type couldn't handle '\(type.kind)' response '\(type)' has '\(type.kind)'.")
                    completion(.failure(error:.invalidResponseKind))
                }
            } else {
                print("\(type(of: self)): Couldn't get any response.")
                completion(.failure(error: .failedRequest))
            }
            }
        case .string: return aRequest.responseString {res in
            if let error = res.result.error {
                print("\(type(of: self)): Internal error while sending request:\n\(error)")
                completion(.failure(error:.networkError))
            } else if let string = res.result.value {
                print("\(type(of: self)): Received string : \(string).")
                if let response = type.init(request: request, body: string) {
                    completion(.success(response: response))
                }
                else {
                   print("\(type(of: self)): Specified response type couldn't handle '\(type.kind)' response '\(type)' has '\(type.kind)'.")
                    completion(.failure(error:.invalidResponseKind))
                }
            } else {
                print("\(type(of: self)): Couldn't get any response.")
                completion(.failure(error: .failedRequest))
            }
            }
        }
    }
}

// MARK: - Mapping abstract enums to Alamofire enums.

fileprivate extension Alamofire.HTTPMethod {
    init(method : RequestMethod) {
        switch method {
        case .get: self = .get
        case .post: self = .post
        case .patch: self = .patch
        case .delete: self = .delete
        case .put: self = .put
        }
    }
}
