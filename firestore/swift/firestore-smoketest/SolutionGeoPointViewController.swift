//
//  Copyright (c) 2019 Google LLC
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
import GeoFireUtils
import CoreLocation

class SolutionGeoPointController: UIViewController {

  var db: Firestore!

  override func viewDidLoad() {
    super.viewDidLoad()
    db = Firestore.firestore()
  }

  func storeGeoHash() {
    // [START fs_geo_add_hash]
    // Compute the GeoHash for a lat/lng point
    let latitude = 51.5074
    let longitude = 0.12780
    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

    let hash = GFUtils.geoHash(forLocation: location)

    // Add the hash and the lat/lng to the document. We will use the hash
    // for queries and the lat/lng for distance comparisons.
    let documentData: [String: Any] = [
      "geohash": hash,
      "lat": latitude,
      "lng": longitude
    ]

    let londonRef = db.collection("cities").document("LON")
    londonRef.updateData(documentData) { error in
      // ...
    }
    // [END fs_geo_add_hash]
  }

  func geoQuery() async {
    // [START fs_geo_query_hashes]
    // Find cities within 50km of London
    let center = CLLocationCoordinate2D(latitude: 51.5074, longitude: 0.1278)
    let radiusInM: Double = 50 * 1000

    // Each item in 'bounds' represents a startAt/endAt pair. We have to issue
    // a separate query for each pair. There can be up to 9 pairs of bounds
    // depending on overlap, but in most cases there are 4.
    let queryBounds = GFUtils.queryBounds(forLocation: center,
                                          withRadius: radiusInM)
    let queries = queryBounds.map { bound -> Query in
      return db.collection("cities")
        .order(by: "geohash")
        .start(at: [bound.startValue])
        .end(at: [bound.endValue])
    }

    @Sendable func fetchMatchingDocs(from query: Query,
                           center: CLLocationCoordinate2D,
                           radiusInMeters: Double) async throws -> [QueryDocumentSnapshot] {
      let snapshot = try await query.getDocuments()
      // Collect all the query results together into a single list
      return snapshot.documents.filter { document in
        let lat = document.data()["lat"] as? Double ?? 0
        let lng = document.data()["lng"] as? Double ?? 0
        let coordinates = CLLocation(latitude: lat, longitude: lng)
        let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)

        // We have to filter out a few false positives due to GeoHash accuracy, but
        // most will match
        let distance = GFUtils.distance(from: centerPoint, to: coordinates)
        return distance <= radiusInM
      }
    }

    // After all callbacks have executed, matchingDocs contains the result. Note that this code
    // executes all queries serially, which may not be optimal for performance.
    do {
      let matchingDocs = try await withThrowingTaskGroup(of: [QueryDocumentSnapshot].self) { group -> [QueryDocumentSnapshot] in
        for query in queries {
          group.addTask {
            try await fetchMatchingDocs(from: query, center: center, radiusInMeters: radiusInM)
          }
        }
        var matchingDocs = [QueryDocumentSnapshot]()
        for try await documents in group {
          matchingDocs.append(contentsOf: documents)
        }
        return matchingDocs
      }

      print("Docs matching geoquery: \(matchingDocs)")
    } catch {
      print("Unable to fetch snapshot data. \(error)")
    }
    // [END fs_geo_query_hashes]
  }
}
