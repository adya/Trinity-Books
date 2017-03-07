import Foundation

/**
 Defines multipart request properties required to perform request call.
 
 - Requires:    iOS  [2.0; 8.0)
 - Requires:    Swift 2+
 - Version:     2.1
 - Since:       10/30/2016
 - Author:      AdYa
 */
public protocol MultipartRequest : Request {
    
    /// File representations with raw data.
    /// - Note: Default = nil.
    var files : [File<Data>]? {get}
    
    /// File representations with URL paths.
    /// - Note: Default = nil.
    var filePaths : [File<URL>]? {get}
    
    /// Defines how parameters should be encoded when embedding into multi-part request.
    /// - Note: Default = NSUTF8StringEncoding.
    var parametersEncoding : UInt {get}
}

/** 
 Represents a file to be uploaded.
 
 - Requires:    iOS  [2.0; 8.0)
 - Requires:    Swift 2+
 - Version:     2.1
 - Since:       10/30/2016
 - Author:      AdYa
 */
public struct File<T> : CustomStringConvertible {
    public let name : String
    public let value : T
    public let fileName : String
    public let mimeType : String
    public init(name : String, value : T, filename : String, mimeType : String) {
        self.name = name
        self.value = value
        self.fileName = filename
        self.mimeType = mimeType
    }
}

// MARK: Defaults
public extension MultipartRequest {
    public var files : [File<Data>]? {
        return nil
    }
    
    public var filePaths : [File<URL>]? {
        return nil
    }
    
    public var parametersEncoding : UInt {
        return String.Encoding.utf8.rawValue
    }
    
    public var encoding : RequestEncoding {
        return .formData
    }
    
    public var description: String {
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
        if let files = self.files {
            descr += "\nFiles:\n"
            files.forEach{
                descr += "\($0.name) of type '\($0.mimeType)' (size: \($0.value.dataSize))\n"
            }
        } else if let files = self.filePaths {
            descr += "\n Files:\n"
            files.forEach{
                descr += "\($0.name) of type '\($0.mimeType)' (at: \($0.value.absoluteString))\n"
            }
        }
        return descr
    }
}

public extension File {
    public var description : String {
        return self.name
    }
}

// TODO: Refactor this with Swift 3.1

public protocol DataWorkaroundProtocol {
    var dataSize : DataSize {get}
}
extension Data : DataWorkaroundProtocol {}

public protocol URLWorkaroundProtocol {
    var absoluteString : String {get}
}
extension URL : URLWorkaroundProtocol {}

public extension File where T : DataWorkaroundProtocol {
    public var description: String {
        return "\(self.name). Type: \(self.mimeType). Size: \(self.value.dataSize)."
    }
}

public extension File where T : URLWorkaroundProtocol {
    public var description: String {
        return "\(self.name). Type: \(self.mimeType). Path: \(self.value.absoluteString)."
    }
}
