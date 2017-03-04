class CommonInjectionPreset : InjectionRulesPreset {
    var rules: [InjectionRule]

    init() {
        rules = [
            InjectionRule(injectable: AnyMessageCellDataSource.self, targetType: String.self) {
                return SimpleMessageCellDataSource(message: $0)
            }
        ]
    }
}
