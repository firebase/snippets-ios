//
//  Copyright (c) 2021 Google Inc.
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
import FirebaseCore
import FirebaseAppCheck

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    return true
  }

  func initCustom() {
    // [START appcheck_initialize_custom]
    let providerFactory = YourAppCheckProviderFactory()
    AppCheck.setAppCheckProviderFactory(providerFactory)

    FirebaseApp.configure()
    // [END appcheck_initialize_custom]
  }

  func initDebug() {
    // [START appcheck_initialize_debug]
    let providerFactory = AppCheckDebugProviderFactory()
    AppCheck.setAppCheckProviderFactory(providerFactory)

    FirebaseApp.configure()
    // [END appcheck_initialize_debug]
  }

  func nonFirebaseBackend() async {
    // [START appcheck_nonfirebase]
    
    do {
      let token = try await AppCheck.appCheck().token(forcingRefresh: false)

      // Get the raw App Check token string.
      let tokenString = token.token

      // Include the App Check token with requests to your server.
      let url = URL(string: "https://yourbackend.example.com/yourApiEndpoint")!
      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      request.setValue(tokenString, forHTTPHeaderField: "X-Firebase-AppCheck")

      let task = URLSession.shared.dataTask(with: request) { data, response, error in
          // Handle response from your backend.
      }
      task.resume()
    } catch(let error) {
      print("Unable to retrieve App Check token: \(error)")
      return
    }
    // [END appcheck_nonfirebase]
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

}

