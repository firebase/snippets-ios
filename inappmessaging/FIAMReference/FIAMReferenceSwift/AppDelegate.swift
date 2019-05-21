//
//  Copyright © 2019 Google. All rights reserved.
//

import UIKit
import Firebase
import FirebaseInAppMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // [START fiam_register_delegate]
        // Register the delegate with the InAppMessaging instance
        let myFiamDelegate = CardActionFiamDelegate()
        InAppMessaging.inAppMessaging().delegate = myFiamDelegate;
        // [END fiam_register_delegate]
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
}

