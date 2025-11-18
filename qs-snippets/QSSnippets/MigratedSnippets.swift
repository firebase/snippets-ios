//
//  Copyright (c) 2025 Google LLC.
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

import FirebaseAnalytics
import FirebaseCore
import FirebaseCrashlytics
import FirebaseRemoteConfig
import FirebaseMessaging
import FirebaseStorage

import AuthenticationServices
import CryptoKit

// [START auth_import]
import FirebaseAuth
// [END auth_import]

// [START google_import]
import GoogleSignIn
// [END google_import]

class DummySceneDelegate: NSObject, UISceneDelegate {
  // [START application_open]
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    // ...
  }
  // [END application_open]
}

class MigratedSnippets {

  func configureFirebase() {
    // [START firebase_configure]
    FirebaseApp.configure()
    // [END firebase_configure]
  }

  func setUserProperty() {
    let food = ""
    // [START user_property]
    Analytics.setUserProperty(food, forName: "favorite_food")
    // [END user_property]
  }

  func logCustomEvent() {
    let name = ""
    let text = ""
    // [START custom_event_swift]
    Analytics.logEvent("share_image", parameters: [
      "name": name,
      "full_text": text,
    ])
    // [END custom_event_swift]
  }

  func logSelectContentEvent() {
    let title = ""
    // formerly custom_event_swift
    // [START log_event_swift]
    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
      AnalyticsParameterItemID: "id-\(title)",
      AnalyticsParameterItemName: title,
      AnalyticsParameterContentType: "cont",
    ])
    // [END log_event_swift]
  }

  func recordScreenView() {
    let screenName = ""
    let screenClass = ""

    // [START set_current_screen]
    Analytics.logEvent(AnalyticsEventScreenView,
                       parameters: [AnalyticsParameterScreenName: screenName,
                                   AnalyticsParameterScreenClass: screenClass])
    // [END set_current_screen]
  }

  private func performGoogleSignInFlow() {
    let viewController = UIViewController()

    // [START headless_google_auth]
    guard let clientID = FirebaseApp.app()?.options.clientID else { return }

    // Create Google Sign In configuration object.
    // [START_EXCLUDE silent]
    // TODO: Move configuration to Info.plist
    // [END_EXCLUDE]
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config

    // Start the sign in flow!
    GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
      guard error == nil else {
        // ...
        return
      }

      guard let user = result?.user,
            let idToken = user.idToken?.tokenString
      else {
        // ...
        return
      }

      let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                     accessToken: user.accessToken.tokenString)
      self.signIn(with: credential)
    }
    // [END headless_google_auth]
  }

  func signIn(with credential: AuthCredential) {
    // [START signin_google_credential]
    Auth.auth().signIn(with: credential) { result, error in
      guard error == nil else {
        // ...
        return
      }

      // At this point, our user is signed in
    }
    // [END signin_google_credential]
  }

  func addConfigUpdateListener() {
    // [START add_config_update_listener]
    RemoteConfig.remoteConfig().addOnConfigUpdateListener { configUpdate, error in
      guard error == nil else { return }
      print("Updated keys: \(configUpdate!.updatedKeys)")

      RemoteConfig.remoteConfig().activate { changed, error in
        guard error == nil else { return }
        // ...
      }
    }
    // [END add_config_update_listener]
  }



}

class SnippetsViewController: UIViewController,
                              ASAuthorizationControllerDelegate,
                              ASAuthorizationControllerPresentationContextProviding {

  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.view.window!
  }

  // [START token_revocation_deleteuser]
  private var currentNonce: String?

  private func deleteCurrentUser() {
    do {
      let nonce = try CryptoUtils.randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = CryptoUtils.sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    } catch {
      // In the unlikely case that nonce generation fails, show error view.
      displayError(error)
    }
  }
  // [END token_revocation_deleteuser]

  // [START token_revocation]
  private var user: User?

  func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
    else {
      print("Unable to retrieve AppleIDCredential")
      return
    }

    guard let _ = currentNonce else {
      fatalError("Invalid state: A login callback was received, but no login request was sent.")
    }

    guard let appleAuthCode = appleIDCredential.authorizationCode else {
      print("Unable to fetch authorization code")
      return
    }

    guard let authCodeString = String(data: appleAuthCode, encoding: .utf8) else {
      print("Unable to serialize auth code string from data: \(appleAuthCode.debugDescription)")
      return
    }

    Task {
      do {
        try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
        try await user?.delete()
        self.updateUI()
      } catch {
        self.displayError(error)
      }
    }
  }
  // [END token_revocation]

  func displayError(_ error: any Error) {
    // do nothing
  }

  func updateUI() {}

  func getRemoteConfig() {
    // [START get_remote_config_instance]
    let remoteConfig = RemoteConfig.remoteConfig()
    // [END get_remote_config_instance]
    print(remoteConfig)
  }

  func enableDeveloperMode() {
    // [START enable_dev_mode]
    let settings = RemoteConfigSettings()
    settings.minimumFetchInterval = 0
    RemoteConfig.remoteConfig().configSettings = settings
    // [END enable_dev_mode]
  }

  func setDefaultValues() {
    // [START set_default_values]
    RemoteConfig.remoteConfig().setDefaults(fromPlist: "RemoteConfigDefaults")
    // [END set_default_values]
  }

  func fetchConfigWithCallback() {
    let remoteConfig = RemoteConfig.remoteConfig()
    // [START fetch_config_with_callback]
    remoteConfig.fetch { (status, error) -> Void in
      if status == .success {
        print("Config fetched!")
        remoteConfig.activate { changed, error in
          // ...
        }
      } else {
        print("Config not fetched")
        print("Error: \(error?.localizedDescription ?? "No error available.")")
      }
    }
    // [END fetch_config_with_callback]
  }

  func getConfigValue() {
    let remoteConfig = RemoteConfig.remoteConfig()
    // [START get_config_value]
    let welcomeMessage = remoteConfig["welcome_message"].stringValue
    // [END get_config_value]
    print(welcomeMessage)
  }

  func logAndCrash() {
    // [START log_and_crash_swift]
    Crashlytics.crashlytics().log("Cause Crash button clicked")
    fatalError()
    // [END log_and_crash_swift]
  }

  func downloadFile() {
    let storageRef = Storage.storage().reference()

    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    let filePath = "file:\(documentsDirectory)/myimage.jpg"
    guard let fileURL = URL(string: filePath) else { return }
    guard let storagePath = UserDefaults.standard.object(forKey: "storagePath") as? String else {
      return
    }
    // [START downloadimage]
    storageRef.child(storagePath).write(toFile: fileURL) { result in
      switch result {
      case let .success(url):
        print(UIImage(contentsOfFile: url.path) ?? "(invalid image)")
      case let .failure(error):
        print("Error downloading:\(error)")
      }
    }
    // [END downloadimage]
  }

  func configureStorage() {
    // [START configurestorage]
    let storage = Storage.storage()
    // [END configurestorage]
    print(storage)
  }

  func storageAuth() {
    // [START storageauth]
    // Using Cloud Storage for Firebase requires the user be authenticated. Here we are using
    // anonymous authentication.
    if Auth.auth().currentUser == nil {
      Auth.auth().signInAnonymously(completion: { authResult, error in
        if let error = error {
          print("Error signing in: \(error)")
        }
      })
    }
    // [END storageauth]
  }

  func uploadFile() {
    let filePath = "example"
    guard let imagePath = Bundle.main.url(forResource: "sample", withExtension: "jpg") else {
      return
    }
    // [START uploadimage]
    let storageRef = Storage.storage().reference(withPath: filePath)
    storageRef.putFile(from: imagePath) { result in
      switch result {
      case .success:
        print("Upload succeeded")
      case let .failure(error):
        print("Error uploading: \(error)")
      }
    }
    // [END uploadimage]
  }

}

class MessagingAppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication
                     .LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()

    // [START set_messaging_delegate]
    Messaging.messaging().delegate = self
    // [END set_messaging_delegate]

    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    // [START register_for_notifications]

    UNUserNotificationCenter.current().delegate = self

    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { _, _ in }
    )

    application.registerForRemoteNotifications()

    // [END register_for_notifications]

    return true
  }

  // [START receive_message]
  @MainActor
  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
    -> UIBackgroundFetchResult {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // ...

    // Print full message.
    print(userInfo)
    print("Call exportDeliveryMetricsToBigQuery() from AppDelegate")
    Messaging.serviceExtension().exportDeliveryMetricsToBigQuery(withMessageInfo: userInfo)
    return UIBackgroundFetchResult.newData
  }
  // [END receive_message]

  // [START ios_10_message_handling]
  // Receive displayed notifications for iOS 10+ devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // ...

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    // Note: UNNotificationPresentationOptions.alert has been deprecated.
    return [.list, .banner, .sound]
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse) async {
    let userInfo = response.notification.request.content.userInfo

    // ...

    // Print full message.
    print(userInfo)
  }
  // [END ios_10_message_handling]

  // [START refresh_token]
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
  }
  // [END refresh_token]

  func logFCMToken() {
    // [START log_fcm_reg_token]
    let token = Messaging.messaging().fcmToken
    print("FCM token: \(token ?? "")")
    // [END log_fcm_reg_token]

    // [START log_iid_reg_token]
    Messaging.messaging().token { token, error in
      if let error = error {
        print("Error fetching remote FCM registration token: \(error)")
      } else if let token = token {
        print("Remote instance ID token: \(token)")
      }
    }
    // [END log_iid_reg_token]
  }

  func subscribeToTopic() {
    // [START subscribe_topic]
    Messaging.messaging().subscribe(toTopic: "weather") { error in
      print("Subscribed to weather topic")
    }
    // [END subscribe_topic]
  }
}
