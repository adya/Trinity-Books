class ProductionInjectionPreset : CommonInjectionPreset {
    
    override init() {
        super.init()
        rules += viewModels
    }
    
    var viewModels : [InjectionRule] {
        return [
            InjectionRule(injectable: AnyBookViewModel.self, targetType: Book.self,  meta: BookViewModel.self) {
                return BookViewModel(book: $0)
            },
            InjectionRule(injectable: AnyBookViewModel.self,
                          targetType: Book.self,
                          destinationType: CartBooksViewModel.self,
                          meta: CartBookViewModel.self) {
                            return CartBookViewModel(book: $0)
            },
            InjectionRule(injectable: AnyBookViewModel.self,
                          targetType: Book.self,
                          destinationType: CartViewController.self,
                          meta: CartBookViewModel.self) {
                            return CartBookViewModel(book: $0)
            },
            
            InjectionRule(injectable: AnyBooksViewModel.self,
                          meta: BooksViewModel.self) {
                            return BooksViewModel()
            },
            InjectionRule(injectable: AnyBooksViewModel.self,
                          targetType: [Book].self,
                          meta: BooksViewModel.self) {
                            return BooksViewModel(books: $0)
            },
            
            InjectionRule(injectable: AnyBooksViewModel.self,
                          destinationType: CartViewController.self,
                          meta: CartBooksViewModel.self) {
                            return CartBooksViewModel()
            },
            InjectionRule(injectable: AnyBooksViewModel.self,
                          targetType: [Book].self,
                          destinationType: CartViewController.self,
                          meta: CartBooksViewModel.self) {
                            return CartBooksViewModel(books: $0)
            }
        ]
    }
}
