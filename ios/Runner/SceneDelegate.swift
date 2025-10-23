import UIKit
import Flutter

@objc(SceneDelegate) // 👈 Ensures Objective-C can find it
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Flutter engine and view controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let flutterViewController = appDelegate.window?.rootViewController as! FlutterViewController

        // Setup main window
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = flutterViewController
        self.window = window
        window.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // MSAL redirect handling (important for auth)
        guard let url = URLContexts.first?.url else { return }
        MSALPublicClientApplication.handleMSALResponse(url)
    }
}
