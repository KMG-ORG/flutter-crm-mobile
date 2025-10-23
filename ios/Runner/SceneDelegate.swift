import UIKit
import Flutter

@objc(SceneDelegate)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Use existing Flutter root view
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let flutterViewController = appDelegate.window?.rootViewController as! FlutterViewController

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = flutterViewController
        self.window = window
        window.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // MSAL / deep link handling
        guard let url = URLContexts.first?.url else { return }
        MSALPublicClientApplication.handleMSALResponse(url)
    }
}
