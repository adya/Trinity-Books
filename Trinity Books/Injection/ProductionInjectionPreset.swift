class ProductionInjectionPreset : CommonInjectionPreset {
    
    override init() {
        super.init()
        rules += viewModels
        rules += managers
    }
    
    var viewModels : [InjectionRule] {
        return [
            InjectionRule(injectable: AnyBookViewModel.self, targetType: Book.self,  meta: BookViewModel.self) {
                return BookViewModel(book: $0)
            },
            InjectionRule(injectable: AnyBookViewModel.self,
                          targetType: Book.self,
                          destinationType: LibraryBooksViewModel.self,
                          meta: LibraryBookViewModel.self) {
                            return LibraryBookViewModel(book: $0)
            },
            InjectionRule(injectable: AnyBookViewModel.self,
                          targetType: Book.self,
                          destinationType: LibraryViewController.self,
                          meta: LibraryBookViewModel.self) {
                            return LibraryBookViewModel(book: $0)
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
                          destinationType: LibraryViewController.self,
                          meta: LibraryBooksViewModel.self) {
                            return LibraryBooksViewModel()
            },
            InjectionRule(injectable: AnyBooksViewModel.self,
                          targetType: [Book].self,
                          destinationType: LibraryViewController.self,
                          meta: LibraryBooksViewModel.self) {
                            return LibraryBooksViewModel(books: $0)
            }
        ]
    }
    
    var managers : [InjectionRule] {
        return [
            InjectionRule(injectable: AnyLibraryManager.self,
                          meta: UserDefaultsLibraryManager.self,
                          injected: UserDefaultsLibraryManager())
        ]
    }
}
