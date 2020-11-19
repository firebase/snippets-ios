//
//  Copyright (c) 2020 Google Inc.
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

import FirebaseCore
import FirebaseInstallations

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }

  var installationIDObserver: NSObjectProtocol?
  func handleInstallationIDChange() {
    // [START handle_installation_id_change]
    installationIDObserver = NotificationCenter.default.addObserver(
            forName: .InstallationIDDidChange,
            object: nil,
            queue: nil
    ) { (notification) in
      // Fetch new Installation ID
      self.fetchInstallationToken()
    }
    // [END handle_installation_id_change]
  }

  func fetchInstallationID() {
    // [START fetch_installation_id]
    Installations.installations().installationID { (id, error) in
      if let error = error {
        print("Error fetching id: \(error)")
        return
      }
      guard let id = id else { return }
      print("Installation ID: \(id)")
    }
    // [END fetch_installation_id]
  }

  func fetchInstallationToken() {
    // [START fetch_installation_token]
    Installations.installations().authTokenForcingRefresh(true, completion: { (token, error) in
      if let error = error {
        print("Error fetching token: \(error)")
        return
      }
      guard let token = token else { return }
      print("Installation auth token: \(token)")
    })
    // [END fetch_installation_token]
  }

  func deleteInstallation() {
    // [START delete_installation]
    Installations.installations().delete { error in
      if let error = error {
        print("Error deleting installation: \(error)")
        return
      }
      print("Installation deleted");
    }
    // [END delete_installation]
  }

}

