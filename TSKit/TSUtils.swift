import Foundation

// MARK: - Grouping
public extension Sequence {
    
    /// Groups any sequence by the key specified in the closure and creates a dictionary.
    public func groupBy<G : Hashable>(_ closure : (Iterator.Element) -> G?) -> [G : [Iterator.Element]] {
        let results : [G: Array<Iterator.Element>] = self.reduce([:]) {
            guard let key = closure($1) else {
                return $0
            }
            var dic = $0
            if var array = dic[key] {
                array.append($1)
                dic[key] = array
            }
            else {
                dic[key] = [$1]
            }
            return dic
        }
        return results
    }
}

// MARK: - Distinct
public extension Sequence where Iterator.Element: Hashable {
    public var distinct : [Iterator.Element] {
        return Array(Set(self))
    }
}

public extension Sequence where Iterator.Element : Equatable {
    public var distinct : [Iterator.Element] {
        return self.reduce([]){uniqueElements, element in
            uniqueElements.contains(element)
                ? uniqueElements
                : uniqueElements + [element]
        }
    }
}

public extension Sequence {
    public func distinct<T : Equatable>(_ transform: (Self.Iterator.Element) -> T?) -> [Iterator.Element] {
        return self.reduce(([], [])){ (unique : ([T], [Iterator.Element]), element : Iterator.Element) in
            guard let key = transform(element) else {
                return unique
            }
            return unique.0.contains(key)
                ? unique
                : (unique.0 + [key], unique.1 + [element])
            }.1
    }
}

// MARK: Dictionary filtering

public extension Dictionary {
    /// Returns filtered dictionary.
    public func filter(includeElement: (Iterator.Element) throws -> Bool) rethrows -> [Key : Value] {
        var dict = [Key : Value]()
        let res : [Iterator.Element] = try self.filter(includeElement)
        res.forEach { dict[$0.0] = $0.1 }
        return dict
    }
}

// MARK: Array's elements value access.
public extension Array where Element : Equatable {
    
    /// Allows to access element in the array by it's value. This can be handy when you need to update value in the array and don't know its index.
    public subscript (element : Iterator.Element) -> Iterator.Element? {
        get {
            if let index = self.index(of: element) {
                return self[index]
            } else {
                return nil
            }
        }
        set {
            if let index = self.index(of: element) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    self.remove(at: index)
                }
            }
        }
    }
}

public func +=<K, V> (left: inout [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }

// MARK: - Random
/// Adds handy random support.
public extension Range {
    /// Gets random value from the interval.
    public var random : Bound {
        let range = (self.upperBound as! Float) - (self.lowerBound as! Float)
        let randomValue = (Float(arc4random_uniform(UInt32.max)) / Float(UInt32.max)) * range + (self.lowerBound as! Float)
        return randomValue as! Bound
    }
}

public extension Collection {
    /// Gets random value from the range.
    public var random : Self._Element {
        if let startIndex = self.startIndex as? Int {
            let start = UInt32(startIndex)
            let end = UInt32(self.endIndex as! Int)
            return self[Int(arc4random_uniform(end - start) + start) as! Self.Index]
        }
        var generator = self.makeIterator()
        var count = arc4random_uniform(UInt32(self.count as! Int))
        while count > 0 {
            let _ = generator.next()
            count = count - 1
        }
        return generator.next() as! Self._Element
    }
}

public extension Array {
    /// Returns an array containing this sequence shuffled
    public var shuffled : Array {
        var shuffled = self
        self.indices.dropLast().forEach { a in
            guard case let b = Int(arc4random_uniform(UInt32(self.count - a))) + a, b != a else { return }
            shuffled[a] = self[b]
        }
        return self
    }
    
    /// Gets random `n` elements from the array.
    public func random(_ n: Int) -> Array { return Array(self.shuffled.prefix(n)) }

}
