class DummyInjectionPreset : CommonInjectionPreset {

    override init() {
        super.init()
        // add rules here
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
    
    private var cartManager : AnyCartManager {
        return try! Injector.inject(AnyCartManager.self)
    }
    
    var managers : [InjectionRule] {
        return [
            InjectionRule(injectable: AnyCartManager.self,
                          meta: DummyCartManager.self,
                          injected: DummyCartManager()),
            
            InjectionRule(injectable: AnyBooksProvider.self,
                          meta: DummyBooksProvider.self,
                          injected: DummyBooksProvider(cartManager: self.cartManager))
        ]
    }
}
