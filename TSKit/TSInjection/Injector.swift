/**
 Highly configurable powerful injection mechanism.
 
 - Note: Best place to configure `Injector` is in the `AppDelegate`'s `init` method. (This will ensures that by the time you are injecting constants in ViewControllers init methods `Injector` will be ready for that).
 
 - Version:    1.1
 - Date:       11/22/2016
 - Since:      11/03/2016
 - Author:     AdYa
 */
open class Injector {
   
    /// TSTOOLS: Upgrade Injector with ability to specify `for: Any.Type` parameter of injection to distinct injection of the same thing in different places.
    
    /// Used to tag log messages instead of `String(self.dynamicType)` to avoid extra `.Type` at the end of the resulting string.
    fileprivate static let TAG = "Injector"
    
    /// Internal property to store configured injection rules.
    fileprivate static var rules : [String : [String : InjectionRule]] = [:]
    
    fileprivate static var cache : [String : [String : Any]] = [:]
    
    /// Replaces existing `InjectionRule`s with specified in the preset.
    /// - Parameter preset: An array of rules to be set.
    open static func configure(with preset : InjectionRulesPreset) {
        self.configure(with: preset.rules)
    }
    
    /// Replaces existing `InjectionRule`s with specified.
    /// - Parameter rules: An array of rules to be set.
    open static func configure(with rules : [InjectionRule]) {
        rules.forEach { self.addInjectionRule($0) }
    }
    
    /// Adds a single `InjectionRule` to existing rules.
    /// - Parameter rule: A rule to be added.
    open static func addInjectionRule(_ rule : InjectionRule) {
        let protocolType = String(describing: rule.protocolType)
        let targetType = String(describing: rule.targetType)
        // Either add to existing sub-dictionary
        if self.rules[protocolType] != nil {
            self.rules[protocolType]?[targetType] = rule
        } else {
            self.rules[protocolType] = [targetType : rule]
        }
    }
    
    /**
     Injects concrete type conformed to target injectable type.
     - Parameter injectable: Protocol to which injected instance conforms.
     - Parameter parameter: Custom parameter to be used during injection.
     - Parameter InjectableType: Type of the `injectable`.
     
     - Throws:
         * InjectionError.UndefinedInjectionError
         * InjectionError.ParameterCastingError
     */
    open static func inject<InjectableType : Any> (_ injectable : InjectableType.Type, with parameter: Any? = nil) throws -> InjectableType {
        let target : Any.Type // infer target type from given parameter. By default injection rules applied to Any.
        if let param = parameter {
            target = type(of: (param) as AnyObject)
        } else {
            target = Any.Type.self
        }
        let protocolType = "\(injectable)"
        let targetType = "\(target)"
        
        guard let rule = self.rules[protocolType]?[targetType] else {
            print("\(TAG): Didn't find any rule suitable for injection of '\(injectable)' for target '\(target)'.")
            throw InjectionError.undefinedInjectionError
        }
        
        if rule.once, let cached = self.cache[protocolType]?[targetType] as? InjectableType {
            print("\(TAG): Restored cached '\(type(of: injectable))' with '\(type(of: cached))'.")
            return cached
        }
        
        guard let injected = try rule.injection(parameter) as? InjectableType else {
            print("\(TAG): '\(type(of: injectable))' injection failed.")
            throw InjectionError.undefinedInjectionError
        }
        print("\(TAG): Successfully injected '\(type(of: injectable))' with '\(type(of: injected))'.")
        if rule.once {
            if self.cache[protocolType] != nil {
                self.cache[protocolType]?[targetType] = injected
            } else {
                self.cache[protocolType] = [targetType : injected]
            }
        }
        return injected
    }
    
    /// Prints all configured injection rules.
    open static func printConfiguration() {
        print("\(TAG): Configured injection rules: \n")
        self.rules
            .flatMap{$0.1.values}
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
    
    /// Intenral holder for the protocol type.
    fileprivate let protocolType : Any.Type
    
    /// Internal holder for the specific target type of the injection.
    fileprivate let targetType : Any.Type
    
    /// Indicates whether the injection should reuse object created before or not.
    fileprivate let once : Bool
    
    /// Internal holder for an injection closure.
    fileprivate let injection : InjectionClosure
    
    public var description : String {
        return "\(self.protocolType) [\(self.targetType)]"
    }
    
    fileprivate init(protocolType : Any.Type, targetType : Any.Type = Any.Type.self, once : Bool = false, injection : @escaping InjectionClosure) {
        self.protocolType = protocolType
        self.targetType = targetType
        self.once = once
        self.injection = injection
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure with paramter.
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter once: Indicates whether the injection should reuse object created before or not.
    /// - Parameter injection: A closure to which type instantiation is delegated.
    /// - Parameter InjectableType: Type of injectable which must confrom to general Injectable protocol.
    /// - Parameter ParameterType: Type of the parameter which will be passed to the closure.
    public init<InjectableType> (injectable : InjectableType.Type, once : Bool = false, injection : @escaping () throws -> InjectableType) {
        self.init(protocolType: injectable, once: once) { _ in try injection() }
    }
    
    /// Initializes `InjectionRule` with specified target type and injection closure with paramter.
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter once: Indicates whether the injection should reuse object created before or not.
    /// - Parameter injection: A closure to which type instantiation is delegated.
    /// - Parameter InjectableType: Type of injectable which must confrom to general Injectable protocol.
    /// - Parameter ParameterType: Type of the parameter which will be passed to the closure.
    public init<InjectableType, TargetType> (injectable : InjectableType.Type, targetType : TargetType.Type, once : Bool = false, injection : @escaping (TargetType) throws -> InjectableType) {
        self.init(protocolType: injectable, targetType: targetType, once: once) {
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
    
    /// Initializes `InjectionRule` with specified target type and injection closure without parameters.
    /// - Attention: This type of injection will use a single instance to inject it wherever it's requested. (Applicable to classes, since value types will be copied during injection).
    /// - Parameter injectable: Target protocol type to which this rule will be applied.
    /// - Parameter injection: A closure to which type instantiation is delegated.
    /// - Parameter InjectableType: Type of injectable which must confrom to general Injectable protocol.
    public init<InjectableType> (injectable : InjectableType.Type, injected : @autoclosure @escaping () throws -> InjectableType) {
        self.init(protocolType: injectable, once: true) { _ in return try injected() }
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
