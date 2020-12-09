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
import FirebaseFirestoreSwift

class ViewController: UIViewController {

    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()

        // [START setup]
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func didTouchSmokeTestButton(_ sender: AnyObject) {
        // Quickstart
        addAdaLovelace()
        addAlanTuring()
        getCollection()
        listenForUsers()

        // Structure Data
        demonstrateReferences()

        // Save Data
        setDocument()
        dataTypes()
        setData()
        addDocument()
        newDocument()
        updateDocument()
        createIfMissing()
        updateDocumentNested()
        deleteDocument()
        deleteCollection()
        deleteField()
        serverTimestamp()
        serverTimestampOptions()
        simpleTransaction()
        transaction()
        writeBatch()

        // Retrieve Data
        exampleData()
        exampleDataCollectionGroup()
        getDocument()
        customClassGetDocument()
        listenDocument()
        listenDocumentLocal()
        listenWithMetadata()
        getMultiple()
        getMultipleAll()
        listenMultiple()
        listenDiffs()
        listenState()
        detachListener()
        handleListenErrors()

        // Query Data
        simpleQueries()
        exampleFilters()
        onlyCapitals()
        chainFilters()
        validRangeFilters()

        // IN Queries
        arrayContainsAnyQueries()
        inQueries()

        // Can't run this since it throws a fatal error
        // invalidRangeFilters()

        orderAndLimit()
        orderAndLimitDesc()
        orderMultiple()
        filterAndOrder()
        validFilterAndOrder()

        // Can't run this since it throws a fatal error
        // invalidFilterAndOrder()

        // Enable Offline
        // Can't run this since it throws a fatal error
        // enableOffline()
        listenToOffline()
        toggleOffline()
        setupCacheSize()

        // Cursors
        simpleCursor()
        snapshotCursor()
        paginate()
        multiCursor()
    }

    @IBAction func didTouchDeleteButton(_ sender: AnyObject) {
        deleteCollection(collection: "users")
        deleteCollection(collection: "cities")
    }

    private func deleteCollection(collection: String) {
        db.collection(collection).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }

            for document in querySnapshot!.documents {
                print("Deleting \(document.documentID) => \(document.data())")
                document.reference.delete()
            }
        }
    }

    private func setupCacheSize() {
        // [START fs_setup_cache]
        let settings = Firestore.firestore().settings
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
        // [END fs_setup_cache]
    }

    // =======================================================================================
    // ======== https://firebase.google.com/preview/firestore/client/quickstart ==============
    // =======================================================================================

    private func addAdaLovelace() {
        // [START add_ada_lovelace]
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "first": "Ada",
            "last": "Lovelace",
            "born": 1815
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        // [END add_ada_lovelace]
    }

    private func addAlanTuring() {
        var ref: DocumentReference? = nil

        // [START add_alan_turing]
        // Add a second document with a generated ID.
        ref = db.collection("users").addDocument(data: [
            "first": "Alan",
            "middle": "Mathison",
            "last": "Turing",
            "born": 1912
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        // [END add_alan_turing]
    }

    private func getCollection() {
        // [START get_collection]
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
        // [END get_collection]
    }

    private func listenForUsers() {
        // [START listen_for_users]
        // Listen to a query on a collection.
        //
        // We will get a first snapshot with the initial results and a new
        // snapshot each time there is a change in the results.
        db.collection("users")
            .whereField("born", isLessThan: 1900)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error retreiving snapshots \(error!)")
                    return
                }
                print("Current users born before 1900: \(snapshot.documents.map { $0.data() })")
            }
        // [END listen_for_users]
    }

    // =======================================================================================
    // ======= https://firebase.google.com/preview/firestore/client/structure-data ===========
    // =======================================================================================


    private func demonstrateReferences() {
        // [START doc_reference]
        let alovelaceDocumentRef = db.collection("users").document("alovelace")
        // [END doc_reference]
        print(alovelaceDocumentRef)

        // [START collection_reference]
        let usersCollectionRef = db.collection("users")
        // [END collection_reference]
        print(usersCollectionRef)

        // [START subcollection_reference]
        let messageRef = db
            .collection("rooms").document("roomA")
            .collection("messages").document("message1")
        // [END subcollection_reference]
        print(messageRef)

        // [START path_reference]
        let aLovelaceDocumentReference = db.document("users/alovelace")
        // [END path_reference]
        print(aLovelaceDocumentReference)
    }

    // =======================================================================================
    // ========= https://firebase.google.com/preview/firestore/client/save-data ==============
    // =======================================================================================

    private func setDocument() {
        // [START set_document]
        // Add a new document in collection "cities"
        db.collection("cities").document("LA").setData([
            "name": "Los Angeles",
            "state": "CA",
            "country": "USA"
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        // [END set_document]
    }

    private func setDocumentWithCodable() {
        // [START set_document_codable]
        let city = City(name: "Los Angeles",
                        state: "CA",
                        country: "USA",
                        isCapital: false,
                        population: 5000000)

        do {
            try db.collection("cities").document("LA").setData(from: city)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
        // [END set_document_codable]
    }

    private func dataTypes() {
        // [START data_types]
        let docData: [String: Any] = [
            "stringExample": "Hello world!",
            "booleanExample": true,
            "numberExample": 3.14159265,
            "dateExample": Timestamp(date: Date()),
            "arrayExample": [5, true, "hello"],
            "nullExample": NSNull(),
            "objectExample": [
                "a": 5,
                "b": [
                    "nested": "foo"
                ]
            ]
        ]
        db.collection("data").document("one").setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        // [END data_types]
    }

    private func setData() {
        let data: [String: Any] = [:]

        // [START set_data]
        db.collection("cities").document("new-city-id").setData(data)
        // [END set_data]
    }

    private func addDocument() {
        // [START add_document]
        // Add a new document with a generated id.
        var ref: DocumentReference? = nil
        ref = db.collection("cities").addDocument(data: [
            "name": "Tokyo",
            "country": "Japan"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        // [END add_document]
    }

    private func newDocument() {
        // [START new_document]
        let newCityRef = db.collection("cities").document()

        // later...
        newCityRef.setData([
            // [START_EXCLUDE]
            "name": "Some City Name"
            // [END_EXCLUDE]
        ])
        // [END new_document]
    }

    private func updateDocument() {
        // [START update_document]
        let washingtonRef = db.collection("cities").document("DC")

        // Set the "capital" field of the city 'DC'
        washingtonRef.updateData([
            "capital": true
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        // [END update_document]
    }

    private func updateDocumentArray() {
        // [START update_document_array]
        let washingtonRef = db.collection("cities").document("DC")

        // Atomically add a new region to the "regions" array field.
        washingtonRef.updateData([
            "regions": FieldValue.arrayUnion(["greater_virginia"])
        ])

        // Atomically remove a region from the "regions" array field.
        washingtonRef.updateData([
            "regions": FieldValue.arrayRemove(["east_coast"])
        ])
        // [END update_document_array]
    }

    private func updateDocumentIncrement() {
        // [START update_document-increment]
        let washingtonRef = db.collection("cities").document("DC")

        // Atomically increment the population of the city by 50.
        // Note that increment() with no arguments increments by 1.
        washingtonRef.updateData([
            "population": FieldValue.increment(Int64(50))
        ])
        // [END update_document-increment]
    }

    private func createIfMissing() {
        // [START create_if_missing]
        // Update one field, creating the document if it does not exist.
        db.collection("cities").document("BJ").setData([ "capital": true ], merge: true)
        // [END create_if_missing]
    }

    private func updateDocumentNested() {
        // [START update_document_nested]
        // Create an initial document to update.
        let frankDocRef = db.collection("users").document("frank")
        frankDocRef.setData([
            "name": "Frank",
            "favorites": [ "food": "Pizza", "color": "Blue", "subject": "recess" ],
            "age": 12
            ])

        // To update age and favorite color:
        db.collection("users").document("frank").updateData([
            "age": 13,
            "favorites.color": "Red"
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        // [END update_document_nested]
    }

    private func deleteDocument() {
        // [START delete_document]
        db.collection("cities").document("DC").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        // [END delete_document]
    }

    private func deleteCollection() {
        // [START delete_collection]
        func delete(collection: CollectionReference, batchSize: Int = 100, completion: @escaping (Error?) -> ()) {
            // Limit query to avoid out-of-memory errors on large collections.
            // When deleting a collection guaranteed to fit in memory, batching can be avoided entirely.
            collection.limit(to: batchSize).getDocuments { (docset, error) in
                // An error occurred.
                guard let docset = docset else {
                    completion(error)
                    return
                }
                // There's nothing to delete.
                guard docset.count > 0 else {
                    completion(nil)
                    return
                }

                let batch = collection.firestore.batch()
                docset.documents.forEach { batch.deleteDocument($0.reference) }

                batch.commit { (batchError) in
                    if let batchError = batchError {
                        // Stop the deletion process and handle the error. Some elements
                        // may have been deleted.
                        completion(batchError)
                    } else {
                        delete(collection: collection, batchSize: batchSize, completion: completion)
                    }
                }
            }
        }
        // [END delete_collection]
    }

    private func deleteField() {
        // [START delete_field]
        db.collection("cities").document("BJ").updateData([
            "capital": FieldValue.delete(),
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        // [END delete_field]
    }

    private func serverTimestamp() {
        // [START server_timestamp]
        db.collection("objects").document("some-id").updateData([
            "lastUpdated": FieldValue.serverTimestamp(),
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        // [END server_timestamp]
    }

    private func serverTimestampOptions() {
        // [START server_timestamp_options]
        // Perform an update followed by an immediate read without waiting for the update to
        // complete. Due to the snapshot options we will get two results: one with an estimated
        // timestamp and one with a resolved server timestamp.
        let docRef = db.collection("objects").document("some-id")
        docRef.updateData(["timestamp": FieldValue.serverTimestamp()])

        docRef.addSnapshotListener { (snapshot, error) in
            guard let timestamp = snapshot?.data(with: .estimate)?["timestamp"] else { return }
            guard let pendingWrites = snapshot?.metadata.hasPendingWrites else { return }
            print("Timestamp: \(timestamp), pending: \(pendingWrites)")
        }
        // [END server_timestamp_options]
    }

    private func simpleTransaction() {
        // [START simple_transaction]
        let sfReference = db.collection("cities").document("SF")

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let oldPopulation = sfDocument.data()?["population"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }

            // Note: this could be done without a transaction
            //       by updating the population using FieldValue.increment()
            transaction.updateData(["population": oldPopulation + 1], forDocument: sfReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
        // [END simple_transaction]
    }

    private func transaction() {
        // [START transaction]
        let sfReference = db.collection("cities").document("SF")

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let oldPopulation = sfDocument.data()?["population"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }

            // Note: this could be done without a transaction
            //       by updating the population using FieldValue.increment()
            let newPopulation = oldPopulation + 1
            guard newPopulation <= 1000000 else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Population \(newPopulation) too big"]
                )
                errorPointer?.pointee = error
                return nil
            }

            transaction.updateData(["population": newPopulation], forDocument: sfReference)
            return newPopulation
        }) { (object, error) in
            if let error = error {
                print("Error updating population: \(error)")
            } else {
                print("Population increased to \(object!)")
            }
        }
        // [END transaction]
    }

    private func writeBatch() {
        // [START write_batch]
        // Get new write batch
        let batch = db.batch()

        // Set the value of 'NYC'
        let nycRef = db.collection("cities").document("NYC")
        batch.setData([:], forDocument: nycRef)

        // Update the population of 'SF'
        let sfRef = db.collection("cities").document("SF")
        batch.updateData(["population": 1000000 ], forDocument: sfRef)

        // Delete the city 'LA'
        let laRef = db.collection("cities").document("LA")
        batch.deleteDocument(laRef)

        // Commit the batch
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
        // [END write_batch]
    }

    // =======================================================================================
    // ======= https://firebase.google.com/preview/firestore/client/retrieve-data ============
    // =======================================================================================

    private func exampleData() {
        // [START example_data]
        let citiesRef = db.collection("cities")

        citiesRef.document("SF").setData([
            "name": "San Francisco",
            "state": "CA",
            "country": "USA",
            "capital": false,
            "population": 860000,
            "regions": ["west_coast", "norcal"]
            ])
        citiesRef.document("LA").setData([
            "name": "Los Angeles",
            "state": "CA",
            "country": "USA",
            "capital": false,
            "population": 3900000,
            "regions": ["west_coast", "socal"]
            ])
        citiesRef.document("DC").setData([
            "name": "Washington D.C.",
            "country": "USA",
            "capital": true,
            "population": 680000,
            "regions": ["east_coast"]
            ])
        citiesRef.document("TOK").setData([
            "name": "Tokyo",
            "country": "Japan",
            "capital": true,
            "population": 9000000,
            "regions": ["kanto", "honshu"]
            ])
        citiesRef.document("BJ").setData([
            "name": "Beijing",
            "country": "China",
            "capital": true,
            "population": 21500000,
            "regions": ["jingjinji", "hebei"]
            ])
        // [END example_data]
    }

    private func exampleDataCollectionGroup() {
        // [START fs_collection_group_query_data_setup]
        let citiesRef = db.collection("cities")

        var data = ["name": "Golden Gate Bridge", "type": "bridge"]
        citiesRef.document("SF").collection("landmarks").addDocument(data: data)

        data = ["name": "Legion of Honor", "type": "museum"]
        citiesRef.document("SF").collection("landmarks").addDocument(data: data)

        data = ["name": "Griffith Park", "type": "park"]
        citiesRef.document("LA").collection("landmarks").addDocument(data: data)

        data = ["name": "The Getty", "type": "museum"]
        citiesRef.document("LA").collection("landmarks").addDocument(data: data)

        data = ["name": "Lincoln Memorial", "type": "memorial"]
        citiesRef.document("DC").collection("landmarks").addDocument(data: data)

        data = ["name": "National Air and Space Museum", "type": "museum"]
        citiesRef.document("DC").collection("landmarks").addDocument(data: data)

        data = ["name": "Ueno Park", "type": "park"]
        citiesRef.document("TOK").collection("landmarks").addDocument(data: data)

        data = ["name": "National Museum of Nature and Science", "type": "museum"]
        citiesRef.document("TOK").collection("landmarks").addDocument(data: data)

        data = ["name": "Jingshan Park", "type": "park"]
        citiesRef.document("BJ").collection("landmarks").addDocument(data: data)

        data = ["name": "Beijing Ancient Observatory", "type": "museum"]
        citiesRef.document("BJ").collection("landmarks").addDocument(data: data)
        // [END fs_collection_group_query_data_setup]
    }

    private func getDocument() {
        // [START get_document]
        let docRef = db.collection("cities").document("SF")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
        // [END get_document]
    }

    private func getDocumentWithOptions() {
      // [START get_document_options]
      let docRef = db.collection("cities").document("SF")

      // Force the SDK to fetch the document from the cache. Could also specify
      // FirestoreSource.server or FirestoreSource.default.
      docRef.getDocument(source: .cache) { (document, error) in
        if let document = document {
          let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
          print("Cached document data: \(dataDescription)")
        } else {
          print("Document does not exist in cache")
        }
      }
      // [END get_document_options]
    }

    private func customClassGetDocument() {
        // [START custom_type]
        let docRef = db.collection("cities").document("BJ")

        docRef.getDocument { (document, error) in
            // Construct a Result type to encapsulate deserialization errors or
            // successful deserialization. Note that if there is no error thrown
            // the value may still be `nil`, indicating a successful deserialization
            // of a value that does not exist.
            //
            // There are thus three cases to handle, which Swift lets us describe
            // nicely with built-in Result types:
            //
            //      Result
            //        /\
            //   Error  Optional<City>
            //               /\
            //            Nil  City
            let result = Result {
              try document?.data(as: City.self)
            }
            switch result {
            case .success(let city):
                if let city = city {
                    // A `City` value was successfully initialized from the DocumentSnapshot.
                    print("City: \(city)")
                } else {
                    // A nil value was successfully initialized from the DocumentSnapshot,
                    // or the DocumentSnapshot was nil.
                    print("Document does not exist")
                }
            case .failure(let error):
                // A `City` value could not be initialized from the DocumentSnapshot.
                print("Error decoding city: \(error)")
            }
        }
        // [END custom_type]
    }

    private func listenDocument() {
        // [START listen_document]
        db.collection("cities").document("SF")
            .addSnapshotListener { documentSnapshot, error in
              guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
              guard let data = document.data() else {
                print("Document data was empty.")
                return
              }
              print("Current data: \(data)")
            }
        // [END listen_document]
    }

    private func listenDocumentLocal() {
        // [START listen_document_local]
        db.collection("cities").document("SF")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                let source = document.metadata.hasPendingWrites ? "Local" : "Server"
                print("\(source) data: \(document.data() ?? [:])")
            }
        // [END listen_document_local]
    }

    private func listenWithMetadata() {
        // [START listen_with_metadata]
        // Listen to document metadata.
        db.collection("cities").document("SF")
            .addSnapshotListener(includeMetadataChanges: true) { documentSnapshot, error in
                // ...
            }
        // [END listen_with_metadata]
    }

    private func getMultiple() {
        // [START get_multiple]
        db.collection("cities").whereField("capital", isEqualTo: true)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                }
        }
        // [END get_multiple]
    }

    private func getMultipleAll() {
        // [START get_multiple_all]
        db.collection("cities").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
        // [END get_multiple_all]
    }

    private func listenMultiple() {
        // [START listen_multiple]
        db.collection("cities").whereField("state", isEqualTo: "CA")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                let cities = documents.map { $0["name"]! }
                print("Current cities in CA: \(cities)")
            }
        // [END listen_multiple]
    }

    private func listenDiffs() {
        // [START listen_diffs]
        db.collection("cities").whereField("state", isEqualTo: "CA")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        print("New city: \(diff.document.data())")
                    }
                    if (diff.type == .modified) {
                        print("Modified city: \(diff.document.data())")
                    }
                    if (diff.type == .removed) {
                        print("Removed city: \(diff.document.data())")
                    }
                }
            }
        // [END listen_diffs]
    }

    private func listenState() {
        // [START listen_state]
        db.collection("cities").whereField("state", isEqualTo: "CA")
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        print("New city: \(diff.document.data())")
                    }
                }

                if !snapshot.metadata.isFromCache {
                    print("Synced with server state.")
                }
            }
        // [END listen_state]
    }

    private func detachListener() {
        // [START detach_listener]
        let listener = db.collection("cities").addSnapshotListener { querySnapshot, error in
            // [START_EXCLUDE]
            // [END_EXCLUDE]
        }

        // ...

        // Stop listening to changes
        listener.remove()
        // [END detach_listener]
    }

    private func handleListenErrors() {
        // [START handle_listen_errors]
        db.collection("cities")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error retreiving collection: \(error)")
                }
            }
        // [END handle_listen_errors]
    }

    // =======================================================================================
    // ======== https://firebase.google.com/preview/firestore/client/query-data ==============
    // =======================================================================================

    private func simpleQueries() {
        // [START simple_queries]
        // Create a reference to the cities collection
        let citiesRef = db.collection("cities")

        // Create a query against the collection.
        let query = citiesRef.whereField("state", isEqualTo: "CA")
        // [END simple_queries]

        // [START simple_query_not_equal]
        let notEqualQuery = citiesRef.whereField("capital", isNotEqualTo: false)
        // [END simple_query_not_equal]

        print(query)
    }

    private func exampleFilters() {
        let citiesRef = db.collection("cities")

        // [START example_filters]
        citiesRef.whereField("state", isEqualTo: "CA")
        citiesRef.whereField("population", isLessThan: 100000)
        citiesRef.whereField("name", isGreaterThanOrEqualTo: "San Francisco")
        // [END example_filters]
    }

    private func onlyCapitals() {
        // [START only_capitals]
        let capitalCities = db.collection("cities").whereField("capital", isEqualTo: true)
        // [END only_capitals]
        print(capitalCities)
    }

    private func arrayContainsFilter() {
      let citiesRef = db.collection("cities")

      // [START array_contains_filter]
      citiesRef
        .whereField("regions", arrayContains: "west_coast")
      // [END array_contains_filter]
    }

    private func chainFilters() {
        let citiesRef = db.collection("cities")

        // [START chain_filters]
        citiesRef
            .whereField("state", isEqualTo: "CO")
            .whereField("name", isEqualTo: "Denver")
        citiesRef
            .whereField("state", isEqualTo: "CA")
            .whereField("population", isLessThan: 1000000)
        // [END chain_filters]
    }

    private func validRangeFilters() {
        let citiesRef = db.collection("cities")

        // [START valid_range_filters]
        citiesRef
            .whereField("state", isGreaterThanOrEqualTo: "CA")
            .whereField("state", isLessThanOrEqualTo: "IN")
        citiesRef
            .whereField("state", isEqualTo: "CA")
            .whereField("population", isGreaterThan: 1000000)
        // [END valid_range_filters]
    }

    private func invalidRangeFilters() throws {
        let citiesRef = db.collection("cities")

        // [START invalid_range_filters]
        citiesRef
            .whereField("state", isGreaterThanOrEqualTo: "CA")
            .whereField("population", isGreaterThan: 1000000)
        // [END invalid_range_filters]
    }

    private func orderAndLimit() {
        let citiesRef = db.collection("cities")

        // [START order_and_limit]
        citiesRef.order(by: "name").limit(to: 3)
        // [END order_and_limit]
    }

    private func orderAndLimitDesc() {
        let citiesRef = db.collection("cities")

        // [START order_and_limit_desc]
        citiesRef.order(by: "name", descending: true).limit(to: 3)
        // [END order_and_limit_desc]
    }

    private func orderMultiple() {
        let citiesRef = db.collection("cities")

        // [START order_multiple]
        citiesRef
            .order(by: "state")
            .order(by: "population", descending: true)
        // [END order_multiple]
    }

    private func filterAndOrder() {
        let citiesRef = db.collection("cities")

        // [START filter_and_order]
        citiesRef
            .whereField("population", isGreaterThan: 100000)
            .order(by: "population")
            .limit(to: 2)
        // [END filter_and_order]
    }

    private func validFilterAndOrder() {
        let citiesRef = db.collection("cities")

        // [START valid_filter_and_order]
        citiesRef
            .whereField("population", isGreaterThan: 100000)
            .order(by: "population")
        // [END valid_filter_and_order]
    }

    private func invalidFilterAndOrder() throws {
        let citiesRef = db.collection("cities")

        // [START invalid_filter_and_order]
        citiesRef
            .whereField("population", isGreaterThan: 100000)
            .order(by: "country")
        // [END invalid_filter_and_order]
    }

    private func arrayContainsAnyQueries() {
        // [START array_contains_any_filter]
        let citiesRef = db.collection("cities")
        citiesRef.whereField("regions", arrayContainsAny: ["west_coast", "east_coast"])
        // [END array_contains_any_filter]
    }

    private func inQueries() {
        // [START in_filter]
        let citiesRef = db.collection("cities")

        citiesRef.whereField("country", in: ["USA", "Japan"])
        // [END in_filter]

        // [START in_filter_with_array]
        citiesRef.whereField("regions", in: [["west_coast"], ["east_coast"]]);
        // [END in_filter_with_array]

        // [START not_in_filter]
        citiesRef.whereField("country", notIn: ["USA", "Japan"])
        // [END not_in_filter]
    }

    // =======================================================================================
    // ====== https://firebase.google.com/preview/firestore/client/enable-offline ============
    // =======================================================================================

    private func enableOffline() {
        // [START enable_offline]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true

        // Any additional options
        // ...

        // Enable offline data persistence
        let db = Firestore.firestore()
        db.settings = settings
        // [END enable_offline]
    }

    private func listenToOffline() {
        let db = Firestore.firestore()
        // [START listen_to_offline]
        // Listen to metadata updates to receive a server snapshot even if
        // the data is the same as the cached data.
        db.collection("cities").whereField("state", isEqualTo: "CA")
            .addSnapshotListener(includeMetadataChanges: true) { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error retreiving snapshot: \(error!)")
                    return
                }

                for diff in snapshot.documentChanges {
                    if diff.type == .added {
                        print("New city: \(diff.document.data())")
                    }
                }

                let source = snapshot.metadata.isFromCache ? "local cache" : "server"
                print("Metadata: Data fetched from \(source)")
        }
        // [END listen_to_offline]
    }

    private func toggleOffline() {
        // [START disable_network]
        Firestore.firestore().disableNetwork { (error) in
            // Do offline things
            // ...
        }
        // [END disable_network]

        // [START enable_network]
        Firestore.firestore().enableNetwork { (error) in
            // Do online things
            // ...
        }
        // [END enable_network]
    }

    // =======================================================================================
    // ====== https://firebase.google.com/preview/firestore/client/cursors ===================
    // =======================================================================================

    private func simpleCursor() {
        let db = Firestore.firestore()

        // [START cursor_greater_than]
        // Get all cities with population over one million, ordered by population.
        db.collection("cities")
            .order(by: "population")
            .start(at: [1000000])
        // [END cursor_greater_than]

        // [START cursor_less_than]
        // Get all cities with population less than one million, ordered by population.
        db.collection("cities")
            .order(by: "population")
            .end(at: [1000000])
        // [END cursor_less_than]
    }

    private func snapshotCursor() {
        let db = Firestore.firestore()

        // [START snapshot_cursor]
        db.collection("cities")
            .document("SF")
            .addSnapshotListener { (document, error) in
                guard let document = document else {
                    print("Error retreving cities: \(error.debugDescription)")
                    return
                }

                // Get all cities with a population greater than or equal to San Francisco.
                let sfSizeOrBigger = db.collection("cities")
                    .order(by: "population")
                    .start(atDocument: document)
        }
        // [END snapshot_cursor]
    }

    private func paginate() {
        let db = Firestore.firestore()

        // [START paginate]
        // Construct query for first 25 cities, ordered by population
        let first = db.collection("cities")
            .order(by: "population")
            .limit(to: 25)

        first.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retreving cities: \(error.debugDescription)")
                return
            }

            guard let lastSnapshot = snapshot.documents.last else {
                // The collection is empty.
                return
            }

            // Construct a new query starting after this document,
            // retrieving the next 25 cities.
            let next = db.collection("cities")
                .order(by: "population")
                .start(afterDocument: lastSnapshot)

            // Use the query for pagination.
            // ...
        }
        // [END paginate]
    }

    private func multiCursor() {
        let db = Firestore.firestore()

        // [START multi_cursor]
        // Will return all Springfields
        db.collection("cities")
            .order(by: "name")
            .order(by: "state")
            .start(at: ["Springfield"])

        // Will return "Springfield, Missouri" and "Springfield, Wisconsin"
        db.collection("cities")
            .order(by: "name")
            .order(by: "state")
            .start(at: ["Springfield", "Missouri"])
        // [END multi_cursor]
    }

    private func collectionGroupQuery() {
        // [START fs_collection_group_query]
        db.collectionGroup("landmarks").whereField("type", isEqualTo: "museum").getDocuments { (snapshot, error) in
            // [START_EXCLUDE]
            print(snapshot?.documents.count ?? 0)
            // [END_EXCLUDE]
        }
        // [END fs_collection_group_query]
    }

    private func emulatorSettings() {
        // [START fs_emulator_connect]
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isPersistenceEnabled = false 
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
        // [END fs_emulator_connect]
    }
}

// [START codable_struct]
public struct City: Codable {

    let name: String
    let state: String?
    let country: String?
    let isCapital: Bool?
    let population: Int64?

    enum CodingKeys: String, CodingKey {
        case name
        case state
        case country
        case isCapital = "capital"
        case population
    }

}
// [END codable_struct]
