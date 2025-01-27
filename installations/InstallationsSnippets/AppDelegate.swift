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

import UIKit
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
      Task {
        await self.fetchInstallationToken()
      }
    }
    // [END handle_installation_id_change]
  }

  func fetchInstallationID() async {
    // [START fetch_installation_id]
    do {
      let id = try await Installations.installations().installationID()
      print("Installation ID: \(id)")
    } catch {
      print("Error fetching id: \(error)")
    }
    // [END fetch_installation_id]
  }

  func fetchInstallationToken() async {
    // [START fetch_installation_token]
    do {
      let result = try await Installations.installations()
        .authTokenForcingRefresh(true)
      print("Installation auth token: \(result.authToken)")
    } catch {
      print("Error fetching token: \(error)")
    }
    // [END fetch_installation_token]
  }

  func deleteInstallation() async {
    // [START delete_installation]
    do {
      try await Installations.installations().delete()
      print("Installation deleted");
    } catch {
      print("Error deleting installation: \(error)")
    }
    // [END delete_installation]
  }

}

