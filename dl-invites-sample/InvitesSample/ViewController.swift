//
//  Copyright (c) 2019 Google Inc.
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

import FirebaseDynamicLinks

class ViewController: UIViewController {

  @IBOutlet var linkLabel: UILabel!

  // [START share_controller]
  lazy private var shareController: UIActivityViewController = {
    let activities: [Any] = [
      "Learn how to share content via Firebase",
      URL(string: "https://firebase.google.com")!
    ]
    let controller = UIActivityViewController(activityItems: activities,
                                              applicationActivities: nil)
    return controller
  }()
  
  @IBAction func shareButtonPressed(_ sender: Any) {
    let inviteController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "InviteViewController")
    self.navigationController?.pushViewController(inviteController, animated: true)
  }
  // [END share_controller]

  // [START generate_link]
  func generateContentLink() -> URL {
    let baseURL = URL(string: "https://your-custom-name.page.link")!
    let domain = "https://your-app.page.link"
    let linkBuilder = DynamicLinkComponents(link: baseURL, domainURIPrefix: domain)
    linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.your.bundleID")
    linkBuilder?.androidParameters =
        DynamicLinkAndroidParameters(packageName: "com.your.packageName")


    // Fall back to the base url if we can't generate a dynamic link.
    return linkBuilder?.link ?? baseURL
  }
  // [END generate_link]

  @IBAction func shareLinkButtonPressed(_ sender: Any) {
    guard let item = sender as? UIView else { return }
    shareController.popoverPresentationController?.sourceView = item
    self.present(shareController, animated: true, completion: nil)
  }

}
