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

class ViewController: UIViewController {
  // [START crashlytics_define]
  lazy var crashlytics = Crashlytics.crashlytics()
  // [END crashlytics_define]

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

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
}
