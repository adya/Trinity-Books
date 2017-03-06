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
    
    var managers : [InjectionRule] {
        return [
            InjectionRule(injectable: AnyCartManager.self,
                          injected: DummyCartManager(),
                          meta: DummyCartManager.self)
        ]
    }
}
