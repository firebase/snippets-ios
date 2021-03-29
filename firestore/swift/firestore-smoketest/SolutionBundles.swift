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

  // Loads a remote bundle from the provided url.
  func fetchRemoteBundle(for firestore: Firestore,
                         from url: URL,
                         completion: @escaping ((Result<LoadBundleTaskProgress, Error>) -> ())) {
    guard let inputStream = InputStream(url: url) else {
      let error = self.bundleLoadError(reason: "Unable to create stream from the given url: \(url)")
      completion(.failure(error))
      return
    }

    // The return value of this function is ignored, but can be used for more granular
    // bundle load observation.
    let _ = firestore.loadBundle(inputStream) { (progress, error) in
      switch (progress, error) {

      case (.some(let value), .none):
        if value.state == .success {
          completion(.success(value))
        } else {
          let concreteError = self.bundleLoadError(
            reason: "Expected bundle load to be completed, but got \(value.state) instead"
          )
          completion(.failure(concreteError))
        }

      case (.none, .some(let concreteError)):
        completion(.failure(concreteError))

      case (.none, .none):
        let concreteError = self.bundleLoadError(reason: "Operation failed, but returned no error.")
        completion(.failure(concreteError))

      case (.some(let value), .some(let concreteError)):
        let concreteError = self.bundleLoadError(
          reason: "Operation returned error \(concreteError) with nonnull progress: \(value)"
        )
        completion(.failure(concreteError))
      }
    }
  }

  // Fetches a specific named query from the provided bundle.
  func loadQuery(named queryName: String,
                 fromRemoteBundle bundleURL: URL,
                 with store: Firestore,
                 completion: @escaping ((Result<Query, Error>) -> ())) {
    fetchRemoteBundle(for: store,
                      from: bundleURL) { (result) in
      switch result {
      case .success:
        store.getQuery(named: queryName) { query in
          if let query = query {
            completion(.success(query))
          } else {
            completion(
              .failure(
                self.bundleLoadError(reason: "Could not find query named \(queryName)")
              )
            )
          }
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // Load a query and fetch its results from a bundle.
  func runStoriesQuery() {
    let queryName = "latest-stories-query"
    let firestore = Firestore.firestore()
    let remoteBundle = URL(string: "https://example.com/createBundle")!
    loadQuery(named: queryName,
              fromRemoteBundle: remoteBundle,
              with: firestore) { (result) in
      switch result {
      case .failure(let error):
        print(error)

      case .success(let query):
        query.getDocuments { (snapshot, error) in

          // handle query results

        }
      }
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
  func runNamedQuery() {
    let firestore = Firestore.firestore()
    firestore.getQuery(named: "coll-query") { query in
      query?.getDocuments { (snapshot, error) in
        // ...
      }
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
