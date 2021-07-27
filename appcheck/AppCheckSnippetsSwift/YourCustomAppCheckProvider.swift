//
//  YourCustomAppCheckProvider.swift
//  AppCheckSnippetsSwift
//
//  Created by Kevin Cheung on 7/26/21.
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
                expirationDate: exp - 60  // Refresh the token early to handle clock skew.
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
