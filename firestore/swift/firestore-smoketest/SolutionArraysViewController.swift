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

import FirebaseCore
import FirebaseFirestore

class SolutionArraysViewController: UIViewController {

    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
    }

    func queryInCategory() {
        // [START query_in_category]
        db.collection("posts")
            .whereField("categories.cats", isEqualTo: true)
            .getDocuments() { (querySnapshot, err) in

                // ...

        }
        // [END query_in_category]
    }

    func queryInCategoryTimestamp() {
        // [START query_in_category_timestamp_invalid]
        db.collection("posts")
            .whereField("categories.cats", isEqualTo: true)
            .order(by: "timestamp")
        // [END query_in_category_timestamp_invalid]

        // [START query_in_category_timestamp]
        db.collection("posts")
            .whereField("categories.cats", isGreaterThan: 0)
            .order(by: "categories.cats")
        // [END query_in_category_timestamp]
    }

    // [START post_with_array]
    struct PostArray {

        let title: String
        let categories: [String]

        init(title: String, categories: [String]) {
            self.title = title
            self.categories = categories
        }

    }

    let myArrayPost = PostArray(title: "My great post",
                                categories: ["technology", "opinion", "cats"])
    // [END post_with_array]

    // [START post_with_dict]
    struct PostDict {

        let title: String
        let categories: [String: Bool]

        init(title: String, categories: [String: Bool]) {
            self.title = title
            self.categories = categories
        }

    }

    let post = PostDict(title: "My great post", categories: [
        "technology": true,
        "opinion": true,
        "cats": true
    ])
    // [END post_with_dict]

    // [START post_with_dict_advanced]
    struct PostDictAdvanced {

        let title: String
        let categories: [String: UInt64]

        init(title: String, categories: [String: UInt64]) {
            self.title = title
            self.categories = categories
        }

    }

    let dictPost = PostDictAdvanced(title: "My great post", categories: [
        "technology": 1502144665,
        "opinion": 1502144665,
        "cats": 1502144665
    ])
    // [END post_with_dict_advanced]

}
