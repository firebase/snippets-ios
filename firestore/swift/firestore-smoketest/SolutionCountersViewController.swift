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

class SolutionCountersController: UIViewController {

    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
    }

    // [START counter_structs]
    // counters/${ID}
    struct Counter {
        let numShards: Int

        init(numShards: Int) {
            self.numShards = numShards
        }
    }

    // counters/${ID}/shards/${NUM}
    struct Shard {
        let count: Int

        init(count: Int) {
            self.count = count
        }
    }
    // [END counter_structs]

    // [START create_counter]
    func createCounter(ref: DocumentReference, numShards: Int) {
        ref.setData(["numShards": numShards]){ (err) in
            for i in 0...numShards {
                ref.collection("shards").document(String(i)).setData(["count": 0])
            }
        }
    }
    // [END create_counter]

    // [START increment_counter]
    func incrementCounter(ref: DocumentReference, numShards: Int) {
        // Select a shard of the counter at random
        let shardId = Int(arc4random_uniform(UInt32(numShards)))
        let shardRef = ref.collection("shards").document(String(shardId))

        shardRef.updateData([
            "count": FieldValue.increment(Int64(1))
        ])
    }
    // [END increment_counter]

    // [START get_count]
    func getCount(ref: DocumentReference) {
        ref.collection("shards").getDocuments() { (querySnapshot, err) in
            var totalCount = 0
            if err != nil {
                // Error getting shards
                // ...
            } else {
                for document in querySnapshot!.documents {
                    let count = document.data()["count"] as! Int
                    totalCount += count
                }
            }

            print("Total count is \(totalCount)")
        }
    }
    // [END get_count]
}
