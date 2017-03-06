class CommonInjectionPreset : InjectionRulesPreset {
    var rules: [InjectionRule]

    init() {
        rules = [
            InjectionRule(injectable: AnyMessageCellDataSource.self, targetType: String.self, meta: SimpleMessageCellDataSource.self) {
                return SimpleMessageCellDataSource(message: $0)
            }
        ]
    }
}
