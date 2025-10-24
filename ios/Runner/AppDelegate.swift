//import Flutter
//import UIKit
//
//@main
//@objc class AppDelegate: FlutterAppDelegate {
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//    GeneratedPluginRegistrant.register(with: self)
//    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//  }
//}

import Flutter
import UIKit
import MSAL   // ✅ Make sure this import exists if you use MSAL
import msal_auth
import flutter_secure_storage

@main
@objc class AppDelegate: FlutterAppDelegate {
//    lazy var flutterEngine = FlutterEngine(name: "msal_auth_engine")
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//      flutterEngine.run()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    override func application(
      _ app: UIApplication,
      open url: URL,
      options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
      let sourceApplication = options[.sourceApplication] as? String
      if MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApplication) {
        return true
      }

      return super.application(app, open: url, options: options)
    }


}




