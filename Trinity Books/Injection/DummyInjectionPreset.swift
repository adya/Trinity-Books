class DummyInjectionPreset : CommonInjectionPreset {

    override init() {
        super.init()
        // add rules here
        rules += viewModels
    }

    var viewModels : [InjectionRule] {
        return [
            InjectionRule(injectable: AnyBookViewModel.self) {
                return DummyBookViewModel()
            },
            InjectionRule(injectable: AnyBooksViewModel.self) {
                return DummyBooksViewModel()
            }
        ]
    }
}
