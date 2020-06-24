//
//  Copyright (c) 2017 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // [START default_configure]
    // Use the default GoogleService-Info.plist.
    FirebaseApp.configure()
    // [END default_configure]
    FirebaseApp.app()?.delete({ (success) in

    }) // Delete app as we recreate below.

    // [START default_configure_file]
    // Load a named file.
    let filePath = Bundle.main.path(forResource: "MyGoogleService", ofType: "plist")
    guard let fileopts = FirebaseOptions(contentsOfFile: filePath!)
      else { assert(false, "Couldn't load config file") }
    FirebaseApp.configure(options: fileopts)
    // [END default_configure_file]

    // Note: this one is not deleted, so is the default below.
    // [START default_configure_vars]
    // Configure with manual options. Note that projectID and apiKey, though not
    // required by the initializer, are mandatory.
    let secondaryOptions = FirebaseOptions(googleAppID: "1:27992087142:ios:2a4732a34787067a",
                                           gcmSenderID: "27992087142")
    secondaryOptions.apiKey = "AIzaSyBicqfAZPvMgC7NZkjayUEsrepxuXzZDsk"
    secondaryOptions.projectID = "projectid-12345"

    // The other options are not mandatory, but may be required
    // for specific Firebase products.
    secondaryOptions.bundleID = "com.google.firebase.devrel.FiroptionConfiguration"
    secondaryOptions.trackingID = "UA-12345678-1"
    secondaryOptions.clientID = "27992087142-ola6qe637ulk8780vl8mo5vogegkm23n.apps.googleusercontent.com"
    secondaryOptions.databaseURL = "https://myproject.firebaseio.com"
    secondaryOptions.storageBucket = "myproject.appspot.com"
    secondaryOptions.androidClientID = "12345.apps.googleusercontent.com"
    secondaryOptions.deepLinkURLScheme = "myapp://"
    secondaryOptions.storageBucket = "projectid-12345.appspot.com"
    secondaryOptions.appGroupID = nil
    // [END default_configure_vars]


    // [START default_secondary]
    // Configure an alternative FIRApp.
    FirebaseApp.configure(name: "secondary", options: secondaryOptions)

    // Retrieve a previous created named app.
    guard let secondary = FirebaseApp.app(name: "secondary")
      else { assert(false, "Could not retrieve secondary app") }


    // Retrieve a Real Time Database client configured against a specific app.
    let secondaryDb = Database.database(app: secondary)
    // [END default_secondary]

    // Retrieve a Real Time Database client configured against the default app.
    let defaultDb = Database.database()

    guard let defapp = FirebaseApp.app()
      else { assert(false, "Could not retrieve default app") }

    assert(secondaryDb.app == secondary)
    assert(defaultDb.app == defapp)

    return true
  }

}

