import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override init() {
        super.init()
        Injector.configure(with: DummyInjectionPreset())
        Injector.configure(with: ProductionInjectionPreset())
        Injector.configure(with: CoreDataInjectionPreset())        
        Injector.printConfiguration()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}
