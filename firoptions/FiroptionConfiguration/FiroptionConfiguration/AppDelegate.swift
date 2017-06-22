import UIKit
import Firebase
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    // [START default_configure]
    // Use the default GoogleService-Info.plist.
    FirebaseApp.configure()
    // [END default_configure]
    FirebaseApp.app()?.delete({ (success) in

    }) // Delete app as we recreate below.

    // [START default_configure_file]
    // Load a named file.
    let filePath = Bundle.main.path(forResource: "MyGoogleService", ofType: "plist")
    guard let fileopts = FirebaseOptions.init(contentsOfFile: filePath!)
      else { assert(false, "Couldn't load config file") }
    FirebaseApp.configure(options: fileopts)
    // [END default_configure_file]

    // Note: this one is not deleted, so is the default below.
    // [START default_configure_vars]
    // Configure with manual options.
    let secondaryOptions = FirebaseOptions.init(googleAppID: "1:27992087142:ios:2a4732a34787067a", gcmSenderID: "27992087142")
    secondaryOptions.bundleID = "com.google.firebase.devrel.FiroptionConfiguration"
    secondaryOptions.apiKey = "AIzaSyBicqfAZPvMgC7NZkjayUEsrepxuXzZDsk"
    secondaryOptions.clientID = "27992087142-ola6qe637ulk8780vl8mo5vogegkm23n.apps.googleusercontent.com"
    secondaryOptions.databaseURL = "https://myproject.firebaseio.com"
    secondaryOptions.storageBucket = "myproject.appspot.com"
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

