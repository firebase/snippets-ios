//
//  Copyright (c) 2021 Google LLC
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

import FirebaseFirestore

class SolutionBundles {

  // [START fs_bundle_load]
  // Utility function for errors when loading bundles.
  func bundleLoadError(reason: String) -> NSError {
    return NSError(domain: "FIRSampleErrorDomain",
                   code: 0,
                   userInfo: [NSLocalizedFailureReasonErrorKey: reason])
  }

  func fetchRemoteBundle(for firestore: Firestore,
                         from url: URL) async throws -> LoadBundleTaskProgress {
    guard let inputStream = InputStream(url: url) else {
      let error = self.bundleLoadError(reason: "Unable to create stream from the given url: \(url)")
      throw error
    }

    return try await firestore.loadBundle(inputStream)
  }

  // Fetches a specific named query from the provided bundle.
  func loadQuery(named queryName: String,
                 fromRemoteBundle bundleURL: URL,
                 with store: Firestore) async throws -> Query {
    let _ = try await fetchRemoteBundle(for: store, from: bundleURL)
    if let query = await store.getQuery(named: queryName) {
      return query
    } else {
      throw bundleLoadError(reason: "Could not find query named \(queryName)")
    }
  }

  // Load a query and fetch its results from a bundle.
  func runStoriesQuery() async {
    let queryName = "latest-stories-query"
    let firestore = Firestore.firestore()
    let remoteBundle = URL(string: "https://example.com/createBundle")!

    do {
      let query = try await loadQuery(named: queryName,
                                      fromRemoteBundle: remoteBundle,
                                      with: firestore)
      let snapshot = try await query.getDocuments()
      print(snapshot)
      // handle query results
    } catch {
      print(error)
    }
  }
  // [END fs_bundle_load]

  // [START fs_simple_bundle_load]
  func loadBundle(from bundleURL: URL) {
    let firestore = Firestore.firestore()
    let data: Data
    do {
     try data = Data(contentsOf: bundleURL)
    } catch {
      print(error)
      return
    }
    firestore.loadBundle(data)
  }
  // [END fs_simple_bundle_load]

  // [START fs_named_query]
  func runNamedQuery() async {
    let firestore = Firestore.firestore()
    let queryName = "coll-query"
    do {
      guard let query = await firestore.getQuery(named: queryName) else {
        throw bundleLoadError(reason: "Could not find query named \(queryName)")
      }
      let snapshot = try await query.getDocuments()
      print(snapshot)
      // ...
    } catch {
      print(error)
    }
  }
  // [END fs_named_query]

  // [START bundle_observe_progress]
  func observeProgress(of loadBundleTask: LoadBundleTask) {
    let handle = loadBundleTask.addObserver { progress in
      print("Loaded \(progress.bytesLoaded) bytes out of \(progress.totalBytes) total")
    }

    // ...
    loadBundleTask.removeObserverWith(handle: handle)
  }
  // [END bundle_observe_progress]

}
