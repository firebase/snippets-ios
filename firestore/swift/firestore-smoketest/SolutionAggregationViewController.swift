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

class SolutionAggregationViewController: UIViewController {

    var db: Firestore!

    // [START restaurant_struct]
    struct Restaurant {

        let name: String
        let avgRating: Float
        let numRatings: Int

        init(name: String, avgRating: Float, numRatings: Int) {
            self.name = name
            self.avgRating = avgRating
            self.numRatings = numRatings
        }

    }

    let arinell = Restaurant(name: "Arinell Pizza", avgRating: 4.65, numRatings: 683)
    // [END restaurant_struct]

    struct Rating {
        let rating: Float
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
    }

    func getRatingsSubcollection() {
        // [START get_ratings_subcollection]
        db.collection("restaurants")
            .document("arinell-pizza")
            .collection("ratings")
            .getDocuments() { (querySnapshot, err) in

                // ...

        }
        // [END get_ratings_subcollection]
    }

    // [START add_rating_transaction]
    func addRatingTransaction(restaurantRef: DocumentReference, rating: Float) {
        let ratingRef: DocumentReference = restaurantRef.collection("ratings").document()

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let restaurantDocument = try transaction.getDocument(restaurantRef).data()
                guard var restaurantData = restaurantDocument else { return nil }

                // Compute new number of ratings
                let numRatings = restaurantData["numRatings"] as! Int
                let newNumRatings = numRatings + 1

                // Compute new average rating
                let avgRating = restaurantData["avgRating"] as! Float
                let oldRatingTotal = avgRating * Float(numRatings)
                let newAvgRating = (oldRatingTotal + rating) / Float(newNumRatings)

                // Set new restaurant info
                restaurantData["numRatings"] = newNumRatings
                restaurantData["avgRating"] = newAvgRating

                // Commit to Firestore
                transaction.setData(restaurantData, forDocument: restaurantRef)
                transaction.setData(["rating": rating], forDocument: ratingRef)
            } catch {
                // Error getting restaurant data
                // ...
            }

            return nil
        }) { (object, err) in
            // ...
        }
    }
    // [END add_rating_transaction]

}
