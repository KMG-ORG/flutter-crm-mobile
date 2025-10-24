////
////  .swift
////  Runner
////
////  Created by Kaushlesh Pandey on 23/10/25.
////
//
//import UIKit
//import Flutter
//import MSAL
//
//@objc(SceneDelegate)
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//    func scene(
//        _ scene: UIScene,
//        willConnectTo session: UISceneSession,
//        options connectionOptions: UIScene.ConnectionOptions
//    ) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        
//        // Safely get FlutterViewController from AppDelegate
//        guard
//            let appDelegate = UIApplication.shared.delegate as? AppDelegate,
//            let flutterViewController = appDelegate.window?.rootViewController as? FlutterViewController
//        else {
//            print("⚠️ Could not get FlutterViewController from AppDelegate")
//            return
//        }
//
//        let window = UIWindow(windowScene: windowScene)
//        window.rootViewController = flutterViewController
//        self.window = window
//        window.makeKeyAndVisible()
//    }
//
//
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        // MSAL / deep link handling
//        guard let url = URLContexts.first?.url else { return }
//        
//        // Extract sourceApplication safely from context
//        let sourceApplication = URLContexts.first?.options.sourceApplication
//        
//        // Pass both arguments to MSAL
//        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApplication)
//    }
//
//}


import UIKit
import Flutter
import MSAL

@objc(SceneDelegate)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Create a new FlutterViewController using the AppDelegate's FlutterEngine
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let flutterViewController = FlutterViewController(
//            engine: appDelegate.flutterEngine,
            nibName: nil,
            bundle: nil
        )

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = flutterViewController
        self.window = window
        window.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        let sourceApplication = URLContexts.first?.options.sourceApplication
        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApplication)
    }
}

