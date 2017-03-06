class DummyInjectionPreset : CommonInjectionPreset {

    override init() {
        super.init()
        rules += viewModels
        rules += managers
    }

    var viewModels : [InjectionRule] {
        return [
            InjectionRule(injectable: AnyBookViewModel.self,
                          meta: DummyBookViewModel.self) {
                return DummyBookViewModel()
            },
          
            InjectionRule(injectable: AnyBooksViewModel.self,
                          meta: DummyBooksViewModel.self) {
                return DummyBooksViewModel()
            }
        ]
    }
    
    private var libraryManager : AnyLibraryManager {
        return try! Injector.inject(AnyLibraryManager.self)
    }
    
    var managers : [InjectionRule] {
        return [
            InjectionRule(injectable: AnyLibraryManager.self,
                          meta: DummyLibraryManager.self,
                          injected: DummyLibraryManager()),
            
            InjectionRule(injectable: AnyBooksProvider.self,
                          meta: DummyBooksProvider.self,
                          injected: DummyBooksProvider(libraryManager: self.libraryManager))
        ]
    }
}
