class CoreDataInjectionPreset : CommonInjectionPreset {
    private var contextProvider : CoreDataContextProvider {
        return try! Injector.inject(CoreDataContextProvider.self)
    }
    override init() {
        super.init()
        rules += [
            InjectionRule(injectable: AnyLibraryManager.self,
                          meta: CoreDataLibraryManager.self,
                          injected: CoreDataLibraryManager(contextProvider: self.contextProvider))
        ]
        
        if #available(iOS 10, *) {
            rules.append(InjectionRule(injectable: CoreDataContextProvider.self,
                                       meta: PersistentContainerCoreDataContextProvider.self,
                                       injected: PersistentContainerCoreDataContextProvider()))
        } else {
            rules.append(InjectionRule(injectable: CoreDataContextProvider.self,
                                       meta: OldCoreDataContextProvider.self,
                                       injected: OldCoreDataContextProvider()))
        }
    }
}
