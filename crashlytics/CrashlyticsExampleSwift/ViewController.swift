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
import Firebase

// [START forceCrash]
class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view, typically from a nib.

    let button = UIButton(type: .roundedRect)
    button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
    button.setTitle("Crash", for: [])
    button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
    view.addSubview(button)
  }

  @IBAction func crashButtonTapped(_ sender: AnyObject) {
    fatalError()
  }
  // [END forceCrash]

  // [START crashlytics_define]
  lazy var crashlytics = Crashlytics.crashlytics()
  // [END crashlytics_define]


  func customizeStackTraces() {
    // [START customizeStackTraces]
    var  ex = ExceptionModel(name:"FooException", reason:"There was a foo.")
    ex.stackTrace = [
      StackFrame(symbol:"makeError", file:"handler.js", line:495),
      StackFrame(symbol:"then", file:"routes.js", line:102),
      StackFrame(symbol:"main", file:"app.js", line:12),
    ]

    crashlytics.record(exceptionModel:ex)
    // [END customizeStackTraces]
  }

  func customizeStackTracesAddress() {
    // [START customizeStackTracesAddress]
    var  ex = ExceptionModel.init(name:"FooException", reason:"There was a foo.")
    ex.stackTrace = [
      StackFrame(address:0xfa12123),
      StackFrame(address:12412412),
      StackFrame(address:194129124),
    ]

    crashlytics.record(exceptionModel:ex)
    // [END customizeStackTracesAddress]
  }

  func setCustomKey() {
    // [START setCustomKey]
    // Set int_key to 100.
    Crashlytics.crashlytics().setCustomValue(100, forKey: "int_key")

    // Set str_key to "hello".
    Crashlytics.crashlytics().setCustomValue("hello", forKey: "str_key")
    // [END setCustomKey]
  }

  func setCustomValue() {
    // [START setCustomValue]
    Crashlytics.crashlytics().setCustomValue(100, forKey: "int_key")

    // Set int_key to 50 from 100.
    Crashlytics.crashlytics().setCustomValue(50, forKey: "int_key")
    // [END setCustomValue]
  }

  func setCustomKeys() {
    // [START setCustomKeys]
    let keysAndValues = [
                     "string key" : "string value",
                     "string key 2" : "string value 2",
                     "boolean key" : true,
                     "boolean key 2" : false,
                     "float key" : 1.01,
                     "float key 2" : 2.02
                    ] as [String : Any]

    Crashlytics.crashlytics().setCustomKeysAndValues(keysAndValues)
    // [END setCustomKeys]
  }

  func enableOptIn() {
    // [START enableOptIn]
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    // [END enableOptIn]
  }

  func logExceptions() {
    // [START createError]
    let userInfo = [
      NSLocalizedDescriptionKey: NSLocalizedString("The request failed.", comment: ""),
      NSLocalizedFailureReasonErrorKey: NSLocalizedString("The response returned a 404.", comment: ""),
      NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Does this page exist?", comment: ""),
      "ProductID": "123456",
      "View": "MainView"
    ]

    let error = NSError.init(domain: NSCocoaErrorDomain,
                             code: -1001,
                             userInfo: userInfo)
    // [END createError]

    // [START recordError]
    Crashlytics.crashlytics().record(error: error)
    // [END recordError]
  }

  func setUserId() {
    // [START setUserId]
    Crashlytics.crashlytics().setUserID("123456789")
    // [END setUserId]
  }
}
