import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        let apiClient = APIClient()
        let repository = ArtworkRepository(apiClient: apiClient)
        let viewModel = ArtworkListViewModel(repository: repository)
        let viewController = ArtworkListViewController(viewModel: viewModel)

        navigationController.viewControllers = [viewController]
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
}
