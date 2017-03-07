import Foundation

// Date: 10/30/2016
public enum DataSizeMetric : Int, CustomStringConvertible {
    case bytes = 0
    case kBytes = 1
    case mBytes = 2
    case gBytes = 3
    case tBytes = 4
    
    public var description: String {
        switch self {
        case .bytes: return "B"
        case .kBytes: return "KB"
        case .mBytes: return "MB"
        case .gBytes: return "GB"
        case .tBytes: return "TB"
        }
    }
}

public struct DataSize : CustomStringConvertible {
    public let metric : DataSizeMetric
    public let value : Double
    
    public var description: String {
        return "\(String(format:"%.2f", self.value)) \(self.metric)"
    }
}

public extension Data {
    
    public func dataSizeIn(_ metric : DataSizeMetric) -> DataSize {
        var size = Double(self.count)
        for _ in 0...metric.rawValue {
            size /= 1024
        }
        return DataSize(metric: metric, value: size)
    }
    
    /** Returns the largest DataSizeMetric which is greater than 1.
     
     data1.length // 1025 bytes.
     let size1 = data.dataSize // 1.001 (KBytes)
     
     data2.length // 1023 bytes
     let size2 = data.dataSize // 1023 (Bytes)
     */
    public var dataSize : DataSize {
        var size = Double(self.count)
        var metricValue = 0
        for i in 0...DataSizeMetric.tBytes.rawValue {
            guard size > 1024 else {
                break
            }
            metricValue = i + 1
            size /= 1024
        }
        return DataSize(metric: DataSizeMetric(rawValue: metricValue)!, value: size)
    }
}
