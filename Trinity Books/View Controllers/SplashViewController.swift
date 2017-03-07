import UIKit

class SplashViewController: UIViewController {
    
    fileprivate enum Segues : String {
        case toMain = "segMain"
    }
    
    fileprivate let manager = try! Injector.inject(AnyLibraryManager.self)
    
    @IBOutlet weak fileprivate var aiLoading: UIActivityIndicatorView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadLibrary()
    }
}

// MARK: - Interactor
private extension SplashViewController {
    
    func loadLibrary() {
        showLoading()
        manager.performLoadLibrary() {
            self.hideLoading()
            switch $0 {
            case .success:
            self.performSegue(withIdentifier: Segues.toMain.rawValue, sender: self)
            case .failure:
                let alert = UIAlertController(title: "Trinity Books", message: "Failed to load your library", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
                    self.loadLibrary()
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Presenter
private extension SplashViewController {
    func showLoading() {
        aiLoading.startAnimating()
    }
    
    func hideLoading() {
        aiLoading.stopAnimating()
    }
    
}

