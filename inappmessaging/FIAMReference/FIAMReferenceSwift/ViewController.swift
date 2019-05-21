//
//  Copyright © 2019 Google. All rights reserved.
//

import UIKit
import FirebaseInAppMessaging

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func suppressMessages() {
        // [START fiam_suppress_messages]
        InAppMessaging.inAppMessaging().messageDisplaySuppressed = true
        // [END fiam_suppress_messages]
    }

    func enableDataCollection() {
        // [START fiam_enable_data_collection]
        // Only needed if FirebaseInAppMessagingAutomaticDataCollectionEnabled is set to NO
        // in Info.plist
        InAppMessaging.inAppMessaging().automaticDataCollectionEnabled = true
        // [END fiam_enable_data_collection]
    }
}

