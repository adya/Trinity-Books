/** 
 Base for all model entities.
 
 - Date: 09/26/16
 */
public protocol Identifiable : Hashable, Equatable {
    var id : Int {get}
    var isValid : Bool {get}
}


public extension Identifiable {

    static var invalidId : Int { return 0 }

    /// Default hashValue is model's id.
    var hashValue: Int {
        return id
    }
    
    var isValid : Bool {
        return self.id != Self.invalidId
    }
}

/// Equality is based on model's hashValue property.
public func == <EntityType : Identifiable> (first : EntityType, second : EntityType) -> Bool {
    return first.hashValue == second.hashValue
}

/// Equality is based on model's hashValue property.
public func != <EntityType : Identifiable> (first : EntityType, second : EntityType) -> Bool {
    return !(first.hashValue == second.hashValue)
}

/** Equality is based on all required properties.
 - Note: Must be overriden by conformed entities in order to compare all properties. Default behavior is the same as regular comparison.
 */
public func === <EntityType : Identifiable> (first : EntityType, second : EntityType) -> Bool {
    return first == second
}

/** Equality is based on all required properties.
 - Note: Must be overriden by conformed entities in order to compare all properties. Default behavior is the same as regular comparison.
 */
public func !== <EntityType : Identifiable> (first : EntityType, second : EntityType) -> Bool {
    return !(first === second)
}


