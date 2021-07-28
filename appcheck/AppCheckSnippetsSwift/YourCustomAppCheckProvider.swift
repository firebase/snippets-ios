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

import Foundation
import Firebase

// [START appcheck_custom_provider]
class YourCustomAppCheckProvider: NSObject, AppCheckProvider {
    var app: FirebaseApp

    init(withFirebaseApp app: FirebaseApp) {
        self.app = app
        super.init()
    }

    func getToken(completion handler: @escaping (AppCheckToken?, Error?) -> Void) {
        DispatchQueue.main.async {
            // Logic to exchange proof of authenticity for an App Check token.
            // [START_EXCLUDE]
            let expirationFromServer = 1000.0
            let tokenFromServer = "token"
            // [END_EXCLUDE]

            // Create AppCheckToken object.
            let exp = Date(timeIntervalSince1970: expirationFromServer)
            let token = AppCheckToken(
                token: tokenFromServer,
                expirationDate: exp
            )

            // Pass the token or error to the completion handler.
            handler(token, nil)
        }
    }
}
// [END appcheck_custom_provider]

// [START appcheck_custom_provider_factory]
class YourCustomAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    return YourCustomAppCheckProvider(withFirebaseApp: app)
  }
}
// [END appcheck_custom_provider_factory]
