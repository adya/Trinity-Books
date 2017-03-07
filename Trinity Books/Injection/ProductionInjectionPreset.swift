class ProductionInjectionPreset : CommonInjectionPreset {
    
    override init() {
        super.init()
        rules += viewModels
        rules += managers
        rules += converters
        rules += other
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
                          meta: SearchBooksViewModel.self) {
                            return SearchBooksViewModel()
            },
            InjectionRule(injectable: AnyBooksViewModel.self,
                          targetType: [Book].self,
                          meta: SearchBooksViewModel.self) {
                            return SearchBooksViewModel(books: $0)
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
    
    private var requestManager: RequestManager {
        return try! Injector.inject(RequestManager.self)
    }
    
    private var requestManagerConfiguration: RequestManagerConfiguration {
        return try! Injector.inject(RequestManagerConfiguration.self)
    }
    
    var managers : [InjectionRule] {
        return [
            InjectionRule(injectable: AnyLibraryManager.self,
                          meta: UserDefaultsLibraryManager.self,
                          injected: UserDefaultsLibraryManager()),
            InjectionRule(injectable: AnyBooksProvider.self,
                          meta: GoogleBooksProvider.self,
                          injected: GoogleBooksProvider(requestManager: self.requestManager)),
            InjectionRule(injectable: RequestManager.self,
                          meta: AlamofireRequestManager.self) {
                            return AlamofireRequestManager(configuration: self.requestManagerConfiguration)
            }
        ]
    }
    
    var converters : [InjectionRule] {
        return [
            InjectionRule(injectable: ResponseConverter<Book>.self,
                          meta: GoogleBooksResponseConverter.self) {
                            return GoogleBooksResponseConverter()
            }
        ]
    }
    
    var other : [InjectionRule] {
        return [
            InjectionRule(injectable: RequestManagerConfiguration.self,
                          meta: GoogleRequestManagerConfiguration.self) {
                            return GoogleRequestManagerConfiguration()
            }
        ]
    }
}
