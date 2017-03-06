/**
 Highly configurable powerful injection mechanism.
 
 - Note: Best place to configure `Injector` is in the `AppDelegate`'s `init` method. (This will ensures that by the time you are injecting constants in ViewControllers init methods `Injector` will be ready for that).
 
 - Version:    1.1
 - Date:       11/22/2016
 - Since:      11/03/2016
 - Author:     AdYa
 */
public class Injector {
   
    /// TSTOOLS: Upgrade Injector with ability to specify `for: Any.Type` parameter of injection to distinct injection of the same thing in different places.
    
    /// Used to tag log messages instead of `String(self.dynamicType)` to avoid extra `.Type` at the end of the resulting string.
    fileprivate static let TAG = "Injector"
    
    /// Internal property to store configured injection rules.
    fileprivate static var rules : [String : [String : [String : InjectionRule]]] = [:]
    
    fileprivate static var cache : [String : [String : [String : Any]]] = [:]
    
    /// Replaces existing `InjectionRule`s with specified in the preset.
    /// - Parameter preset: An array of rules to be set.
    public static func configure(with preset : InjectionRulesPreset) {
        self.configure(with: preset.rules)
    }
    
    /// Replaces existing `InjectionRule`s with specified.
    /// - Parameter rules: An array of rules to be set.
    public static func configure(with rules : [InjectionRule]) {
        rules.forEach { self.addInjectionRule($0) }
    }
    
    /// Adds a single `InjectionRule` to existing rules.
    /// - Parameter rule: A rule to be added.
    public static func addInjectionRule(_ rule : InjectionRule) {
        let protocolType = String(describing: rule.protocolType)
        let targetType = String(describing: rule.targetType)
        let destinationType = String(describing: rule.destinationType)
        
        // Either add to existing sub-dictionary or create new one
        guard self.rules[protocolType] != nil else {
            self.rules[protocolType] = [targetType : [destinationType : rule]]
            return
        }
        
        guard self.rules[protocolType]?[targetType] != nil else {
            self.rules[protocolType]?[targetType] = [destinationType : rule]
            return
        }
        
        self.rules[protocolType]?[targetType]?[destinationType] = rule
    }
    
    /**
     Injects concrete type conformed to target injectable type.
     - Parameter injectable: Protocol to which injected instance conforms.
     - Parameter with parameter: Custom parameter to be used during injection.
     - Parameter for sender: Type of the injection target.
     
     - Throws:
         * InjectionError.UndefinedInjectionError
         * InjectionError.ParameterCastingError
     */
    public static func inject<InjectableType : Any> (_ injectable : InjectableType.Type, with parameter: Any? = nil, for sender: Any.Type) throws -> InjectableType {
        let target : Any.Type = parameter != nil ? type(of: parameter!) : Any.Type.self
        
        let protocolType = String(describing: injectable)
        let targetType = String(describing: target)
        let destinationType = String(describing: sender)
        let defaultType = String(describing: Any.Type.self)
        
        // get rules for specific target or default
        // get rule for specific destination or default
        guard let targetRules = self.rules[protocolType]?[targetType] ?? self.rules[protocolType]?[defaultType],
              let rule = targetRules[destinationType] ?? targetRules[defaultType]
            else {
            print("\(TAG): Didn't find any rule suitable for injection of '\(protocolType)' with target '\(targetType)' for '\(destinationType)'.")
            throw InjectionError.undefinedInjectionError
        }
        
        if rule.once,
            let targetCache = self.cache[protocolType]?[targetType] ?? self.cache[protocolType]?[defaultType],
            let cached = (targetCache[destinationType] ?? targetCache[defaultType] as Any) as? InjectableType {
                print("\(TAG): Restored cached '\(protocolType)' with '\(type(of: cached))'.")
                return cached
        }
        
        guard let injected = try rule.injection(parameter) as? InjectableType else {
            print("\(TAG): '\(protocolType)' injection failed.")
            throw InjectionError.undefinedInjectionError
        }
        print("\(TAG): Successfully injected '\(protocolType)' with '\(type(of: injected))'.")
        if rule.once {
            if self.cache[protocolType] == nil {
                self.cache[protocolType] = [targetType : [destinationType : injected]]
            } else if self.cache[protocolType]?[targetType] == nil {
                self.cache[protocolType]?[targetType] = [destinationType : injected]
            } else {
                self.cache[protocolType]?[targetType]?[destinationType] = injected
            }
        }
        return injected
    }
    
    /**
     Injects concrete type conformed to target injectable type.
     - Parameter injectable: Protocol to which injected instance conforms.
     - Parameter parameter: Custom parameter to be used during injection.
     - Parameter for sender: Injection target.
     
     - Throws:
     * InjectionError.UndefinedInjectionError
     * InjectionError.ParameterCastingError
     */
    public static func inject<InjectableType : Any> (_ injectable : InjectableType.Type,
                              with parameter: Any? = nil,
                              for sender: Any? = nil) throws -> InjectableType {
        let sender : Any.Type = sender != nil ? type(of: sender!) : Any.Type.self
        return try inject(injectable, with: parameter, for: sender)
    }
    
    /// Prints all configured injection rules.
    public static func printConfiguration() {
        print("\(TAG): Configured injection rules: \n")
        self.rules
            .flatMap{$0.1.values}.flatMap{$0.values}
            .sorted{"\($0.0.protocolType)".compare("\($0.1.protocolType)") == .orderedAscending }
            .forEach { print("\($0)")}
    }
}

/// Represents error occured during injection.
public enum InjectionError : Error {
    
    /// Represents failed attempt to cast provided parameter to the type required in the injection closure.
    case parameterCastingError
    
    /// Represents failed attempt to inject type for which `Injector` either hasn't got suitable `InjectionRule` or provided rule was invalid.
    case undefinedInjectionError
}

/// Represents an injection rule. This defines how Injector should construct concrete object for specified protocol type.
public struct InjectionRule : CustomStringConvertible {
    
    fileprivate typealias InjectionClosure = ((Any?) throws -> Any)
    
    /// Intenral holder for the type of a protocol being injected.
    fileprivate let protocolType : Any.Type
    
    /// Internal holder for the specific target type of the injection.
    fileprivate let targetType : Any.Type
    
    /// Internal holder for the type of injection destination.
    fileprivate let destinationType : Any.Type
    
    /// Metadata of the injection represents type of concrete object that will be injected.
    private let meta : Any.Type?
    
    /// Indicates whether the injection should reuse object created before or not.
    fileprivate let once : Bool
    
    /// Internal holder for an injection closure.
    fileprivate let injection : InjectionClosure
    
    public var description : String {
        var descr = "\(protocolType)"
        if targetType != Any.Type.self { descr += " [\(self.targetType)]" }
        if destinationType != Any.Type.self { descr += " -> \(self.destinationType)" }
        if meta != nil { descr += " : \(meta!)" }
        return descr
    }
    
    private init(protocolType: Any.Type,
                   targetType: Any.Type = Any.Type.self,
              destinationType: Any.Type = Any.Type.self,
                         once: Bool = false,
                         meta: Any.Type? = nil,
                    injection: @escaping InjectionClosure) {
        self.protocolType = protocolType
        self.targetType = targetType
        self.destinationType = destinationType
        self.once = once
        self.injection = injection
        self.meta = meta
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure with paramter.
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter once: Indicates whether the injection should reuse object created before or not.
    /// - Parameter meta: Metadata of the injection represents type of the concrete object that will be injected.
    /// - Parameter injection: A closure to which type instantiation is delegated.
    /// - Parameter InjectableType: Type of injectable which must confrom to general Injectable protocol.
    public init<InjectableType> (injectable: InjectableType.Type,
                                       once: Bool = false,
                                       meta: Any.Type? = nil,
                                  injection: @escaping () throws -> InjectableType) {
        
        self.init(injectable: injectable,
                  destinationType: Any.Type.self,
                  once: once,
                  meta: meta,
                  injection: injection)
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure with paramter.
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter destinationType: Type of the injection destination object.
    /// - Parameter once: Indicates whether the injection should reuse object created before or not.
    /// - Parameter meta: Metadata of the injection represents type of the concrete object that will be injected.
    /// - Parameter injection: A closure to which type instantiation is delegated.
    public init<InjectableType, DestinationType> (injectable: InjectableType.Type,
                                             destinationType: DestinationType.Type,
                                                        once: Bool = false,
                                                        meta: Any.Type? = nil,
                                                   injection: @escaping () throws -> InjectableType) {
        
        self.init(protocolType: injectable,
                  destinationType: destinationType,
                  once: once,
                  meta: meta) { _ in try injection() }
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure with paramter.
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter targetType: Type of the parameter which will be passed to the closure.
    /// - Parameter destinationType: Type of the injection destination object.
    /// - Parameter once: Indicates whether the injection should reuse object created before or not.
    /// - Parameter meta: Metadata of the injection represents type of the concrete object that will be injected.
    /// - Parameter injection: A closure to which type instantiation is delegated.
    public init<InjectableType, TargetType, DestinationType> (
                    injectable: InjectableType.Type,
                    targetType: TargetType.Type,
               destinationType: DestinationType.Type,
                          once: Bool = false,
                          meta: Any.Type? = nil,
                     injection: @escaping (TargetType) throws -> InjectableType) {
        
        self.init(protocolType: injectable,
                  targetType: targetType,
                  destinationType: destinationType,
                  once: once,
                  meta: meta) {
            guard let parameter = $0 else {
                print("\(Injector.TAG): Unexpected nil parameter while injecting '\(type(of: injectable))'. Expected '\(TargetType.Type.self)'.")
                throw InjectionError.parameterCastingError
            }
            guard let castedParameter = parameter as? TargetType else {
                print("\(Injector.TAG): Failed to cast parameter for injection of '\(type(of: injectable))'. Expected '\(TargetType.Type.self)', but actual parameter is of type '\(type(of: parameter))'.")
                throw InjectionError.parameterCastingError
            }
            return try injection(castedParameter)
        }
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure with paramter.
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter targetType: Type of the parameter which will be passed to the closure.
    /// - Parameter once: Indicates whether the injection should reuse object created before or not.
    /// - Parameter meta: Metadata of the injection represents type of the concrete object that will be injected.
    /// - Parameter injection: A closure to which type instantiation is delegated.
    public init<InjectableType, TargetType> (
        injectable: InjectableType.Type,
        targetType: TargetType.Type,
              once: Bool = false,
              meta: Any.Type? = nil,
         injection: @escaping (TargetType) throws -> InjectableType) {
        
        self.init(injectable: injectable,
                  targetType: targetType,
                  destinationType: Any.Type.self,
                  once: once,
                  meta: meta,
                  injection: injection)
    }

    
    /// Initializes `InjectionRule` with specified target type and injection closure without parameters.
    /// - Attention: This type of injection will use a single instance to inject it wherever it's requested. (Applicable to classes, since value types will be copied during injection).
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter destinationType: Type of the injection destination object.
    /// - Parameter injected: A closure to which type instantiation is delegated.
    /// - Parameter meta: Metadata of the injection represents type of the concrete object that will be injected.
    public init<InjectableType, DestinationType> (
          injectable: InjectableType.Type,
     destinationType: DestinationType.Type,
                meta: Any.Type? = nil,
            injected: @autoclosure @escaping () throws -> InjectableType) {
        self.init(protocolType: injectable,
                  once: true,
                  meta: meta) { _ in return try injected() }
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure without parameters.
    /// - Attention: This type of injection will use a single instance to inject it wherever it's requested. (Applicable to classes, since value types will be copied during injection).
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter injected: A closure to which type instantiation is delegated.
    /// - Parameter meta: Metadata of the injection represents type of the concrete object that will be injected.
    public init<InjectableType> (
          injectable: InjectableType.Type,
                meta: Any.Type? = nil,
            injected: @autoclosure @escaping () throws -> InjectableType) {
        self.init(injectable: injectable,
                  destinationType: Any.Type.self,
                  meta: meta,
                  injected: injected)
    }
}

/// Convinient way to pass in injection rules into `Injector`.
public protocol InjectionRulesPreset {
    
    /// Rules to be used by `Injector`.
    var rules : [InjectionRule] {get}
}

/// TSTOOLS: Can't be used to constraint injection parameters type because of the way generic protocol are implemented in Swift... (e.g. generic constraint where Injectable.InjectionParameters == ParametersType)

/// Represents any injectable type. Used as an additional precaution to protect you from unintended types to be passed to Injector.
//protocol Injectable {
//        /// Type of Injection parameters.
//        associatedtype InjectionParameters
//}
