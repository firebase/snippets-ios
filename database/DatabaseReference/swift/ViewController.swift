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

class ViewController: UIViewController {

  var ref: DatabaseReference!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func persistenceReference() {
    // [START keep_synchronized]
    let scoresRef = Database.database().reference(withPath: "scores")
    scoresRef.keepSynced(true)
    // [END keep_synchronized]

    // [START stop_sync]
    scoresRef.keepSynced(false)
    // [END stop_sync]
  }

  func loadCached() {
    // [START load_cached]
    let scoresRef = Database.database().reference(withPath: "scores")
    scoresRef.queryOrderedByValue().queryLimited(toLast: 4).observe(.childAdded) { snapshot in
      print("The \(snapshot.key) dinosaur's score is \(snapshot.value ?? "null")")
    }
    // [END load_cached]

    // [START load_more_cached]
    scoresRef.queryOrderedByValue().queryLimited(toLast: 2).observe(.childAdded) { snapshot in
      print("The \(snapshot.key) dinosaur's score is \(snapshot.value ?? "null")")
    }
    // [END load_more_cached]

    // [START disconnected]
    let presenceRef = Database.database().reference(withPath: "disconnectmessage");
    // Write a string when this client loses connection
    presenceRef.onDisconnectSetValue("I disconnected!")
    // [END disconnected]

    // [START remove_disconnect]
    presenceRef.onDisconnectRemoveValue { error, reference in
      if let error = error {
        print("Could not establish onDisconnect event: \(error)")
      }
    }
    // [END remove_disconnect]

    // [START cancel_disconnect]
    presenceRef.onDisconnectSetValue("I disconnected")
    // some time later when we change our minds
    presenceRef.cancelDisconnectOperations()
    // [END cancel_disconnect]

    // [START test_connection]
    let connectedRef = Database.database().reference(withPath: ".info/connected")
    connectedRef.observe(.value, with: { snapshot in
      if snapshot.value as? Bool ?? false {
        print("Connected")
      } else {
        print("Not connected")
      }
    })
    // [END test_connection]

    // [START last_online]
    let userLastOnlineRef = Database.database().reference(withPath: "users/morgan/lastOnline")
    userLastOnlineRef.onDisconnectSetValue(ServerValue.timestamp())
    // [END last_online]

    // [START clock_skew]
    let offsetRef = Database.database().reference(withPath: ".info/serverTimeOffset")
    offsetRef.observe(.value, with: { snapshot in
      if let offset = snapshot.value as? TimeInterval {
        print("Estimated server time in milliseconds: \(Date().timeIntervalSince1970 * 1000 + offset)")
      }
    })
    // [END clock_skew]
  }

  func writeNewUser(_ user: Firebase.User, withUsername username: String) {
    // [START rtdb_write_new_user]
    ref.child("users").child(user.uid).setValue(["username": username])
    // [END rtdb_write_new_user]
  }

  func writeNewUserWithCompletion(_ user: Firebase.User, withUsername username: String) {
    // [START rtdb_write_new_user_completion]
    ref.child("users").child(user.uid).setValue(["username": username]) {
      (error:Error?, ref:DatabaseReference) in
      if let error = error {
        print("Data could not be saved: \(error).")
      } else {
        print("Data saved successfully!")
      }
    }
    // [END rtdb_write_new_user_completion]
  }

  func emulatorSettings(Database: Database) {
	// [START rtdb_emulator_connect]
        // In almost all cases the ns (namespace) is your project ID.
	let db = Database.database(url:@"http://localhost:9000?ns=YOUR_DATABASE_NAMESPACE")
	// [END rtdb_emulator_connect]
  }

  func flushRealtimeDatabase(Database: Database) { 
        // [START rtdb_emulator_flush]
	// With a DatabaseReference, write nil to clear the database.
	Database.database().reference().setValue(nil);
	// [END rtdb_emulator_flush]  
  }

}

func combinedExample() {
  // [START combined]
  // since I can connect from multiple devices, we store each connection instance separately
  // any time that connectionsRef's value is null (i.e. has no children) I am offline
  let myConnectionsRef = Database.database().reference(withPath: "users/morgan/connections")

  // stores the timestamp of my last disconnect (the last time I was seen online)
  let lastOnlineRef = Database.database().reference(withPath: "users/morgan/lastOnline")

  let connectedRef = Database.database().reference(withPath: ".info/connected")

  connectedRef.observe(.value, with: { snapshot in
    // only handle connection established (or I've reconnected after a loss of connection)
    guard let connected = snapshot.value as? Bool, connected else { return }

    // add this device to my connections list
    let con = myConnectionsRef.childByAutoId()

    // when this device disconnects, remove it.
    con.onDisconnectRemoveValue()

    // The onDisconnect() call is before the call to set() itself. This is to avoid a race condition
    // where you set the user's presence to true and the client disconnects before the
    // onDisconnect() operation takes effect, leaving a ghost user.

    // this value could contain info about the device or a timestamp instead of just true
    con.setValue(true)

    // when I disconnect, update the last time I was seen online
    lastOnlineRef.onDisconnectSetValue(ServerValue.timestamp())
  })
  // [END combined]
}

