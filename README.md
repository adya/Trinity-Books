# Trinity-Books

Example project based on MVVM pattern and DI principle.

### UI Features:
* Pagination.
* Swipe on cells.
* Neat animations.
* TableViews auto-update.

### Structure Overview:

* **Models** - Models definitions.
  * Book - stores common book information.
  * BookPortion - represents single response from Google Books API. Contains information about total number of books present.
  * Library - represents user's library.
* **Networking Layer** - Contains requests, response converters and API configuration.
  * GoogleRequestManagerConfiguration - Defines configuration to access Google Books API.
  * GoogleSearchBooksRequest - Defines search request to Google Books API.
  * GoogleBooksResponse - Represents response for search request.
  * GoogleBookResponseConverter - Responsible for converting json to a Book model.
* **Data Managers Layer** - Contains business logic and handles all interactions and data manipulation.
  * *AnyBooksProvider* - Defines an interface to retrieve books information.
     * DummyBooksProvider - Temporary implementation of *AnyBooksProvider* to be used as a stub when implementing *View Controllers*.
     * GoogleBooksProvider - Implementation of *AnyBooksProvider* powered by Google Books API.
  * *AnyLibraryManager* - Defines an interface to interact with library.
     * UserDefaultLibraryManager - Implementation of *AnyLibraryManager* based on UserDefaults.
     * CoreDataLibraryManager - Implementation of *AnyLibraryManager* based on CoreData framework.
  * *CoreDataContextProvider* - Defines an interface to retrieve NSManagedObjectContext.
     * PersistentContainerCoreDataContextProvider - Implements *CoreDataContextProvider* using iOS 10 SDK.
     * OldCoreDataContextProvider - Implements *CoreDataContextProvider* using SDK prior to iOS 10.
* **View Models**
  * *AnyBookCellDataSource* - Defines data source interface to provide data required to present a single book in a *BookCell* cell.
  * *AnyBookViewModel* - Defines an interface to provide data required to present a single book. (Inherits *AnyBookCellDataSource*).
    * DummyBookViewModel - Temporary implementation of *AnyBookViewModel* used as a stub when implementing UI.
    * BookViewModel - Implementation used to represent a single book within search books list.
    * LibraryBookViewModel - Implementation used to represent a single book within library books list.
  * *AnyBooksViewModel* - Defines an interface to provide data required to present list of books.
    * DummyBooksViewModel - Temporary implementation of *AnyBookViewModel* used as a stub when implementing UI.
    * SearchBooksViewModel - Implementation used to represent a list of books on SearchViewController.
    * LibraryBooksViewModel - Implementation used to represent a list of books on LibraryViewController.
  * *AnyMessageCellDataSource* - Defines data source interface to provide data required to present a message in a *MessageCell* cell.
    * SimpleMessageCellDataSource - Simple implementation of *AnyMessageCellDataSource*. 
* **Injection** - Contains injection rules. (Defines all dependencies in the project). These rules are applied in AppDelegate.
  * CommonInjectionPreset - Defines common injection rules required for any configuration.
  * DummyInjectionPreset - Defines injection rules to use Dummy implementations for all protocols.
  * ProductionInjectionPreset - Defines injection rules to use "Production" implementation for all protocols.
  * CoreDataInjectionPreset - Overrides injeciton rules for *AnyLibraryManager* to use CoreData implementation instead of UserDefaults.
  
### External dependencies:
* [TSKit](https://github.com/adya/TSKit) - own library with a set of useful frameworks. (No third-part dependencies)
* [Alamofire](https://github.com/Alamofire/Alamofire) - needless to say.  
