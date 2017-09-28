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

@import Firestore;

#import "ViewController.h"

@interface FSTCity : NSObject

@property (nonatomic, readonly) NSString *name;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end

@implementation FSTCity
- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self != nil) {
    if (dict[@"name"] == nil || ![dict[@"name"] isKindOfClass:[NSString class]]) {
      return nil;
    }
    _name = [dict[@"name"] copy];
  }
  return self;
}
@end

@interface ViewController ()

@property (nonatomic, readwrite) FIRFirestore *db;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Access a Cloud Firestore database instance
  // TODO(samstern): Should not hard-code project ID
  // TODO(samstern): Should not need to use staging host

  NSString *host = @"staging-firestore.sandbox.googleapis.com";

  FIRFirestoreSettings *settings = [[FIRFirestoreSettings alloc] init];
  settings.host = host;
  [FIRFirestore firestore].settings = settings;

  self.db = [FIRFirestore firestore];
}

// =======================================================================================
// ======== https://firebase.google.com/preview/firestore/client/quickstart ==============
// =======================================================================================

- (void)addAdaLovelace {
  // [START add_ada_lovelace]
  // Add a new document with a generated ID
  __block FIRDocumentReference *ref =
      [[self.db collectionWithPath:@"users"] addDocumentWithData:@{
        @"first": @"Ada",
        @"last": @"Lovelace",
        @"born": @1815
      } completion:^(NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Error adding document: %@", error);
        } else {
          NSLog(@"Document added with ID: %@", ref.documentID);
        }
      }];
  // [END add_ada_lovelace]
}

- (void)addAlanTuring {
  // [START add_alan_turing]
  // Add a second document with a generated ID.
  __block FIRDocumentReference *ref =
      [[self.db collectionWithPath:@"users"] addDocumentWithData:@{
        @"first": @"Alan",
        @"middle": @"Mathison",
        @"last": @"Turing",
        @"born": @1912
      } completion:^(NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Error adding document: %@", error);
        } else {
          NSLog(@"Document added with ID: %@", ref.documentID);
        }
      }];
  // [END add_alan_turing]
}

- (void)getCollection {
  // [START get_collection]
  [[self.db collectionWithPath:@"users"]
      getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot,
                                   NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Error getting documents: %@", error);
        } else {
          for (FIRDocumentSnapshot *document in snapshot.documents) {
            NSLog(@"%@ => %@", document.documentID, document.data);
          }
        }
      }];
  // RESULT:
  // user1 => ["first": Ada, "last": Lovelace, "born": 1815]
  // user2 => ["first": Alan, "middle": Mathison, "last": Turing, "born": 1912]
  // [END get_collection]
}

- (void)listenForUsers {
  // [START listen_for_users]
  // Listen to a query on a collection.
  //
  // We will get a first snapshot with the initial results and a new
  // snapshot each time there is a change in the results.
  [[[self.db collectionWithPath:@"users"] queryWhereField:@"born" isLessThan:@1900]
      addSnapshotListener:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Error retreiving snapshots %@", error);
        } else {
          NSMutableArray *users = [NSMutableArray array];
          for (FIRDocumentSnapshot *user in snapshot.documents) {
            [users addObject:user.data];
          }
          NSLog(@"Current users born before 1900: %@", users);
        }
      }];
  // [END listen_for_users]
}

// =======================================================================================
// ======= https://firebase.google.com/preview/firestore/client/structure-data ===========
// =======================================================================================

- (void)demonstrateReferences {
  // [START doc_reference]
  FIRDocumentReference *alovelaceDocumentRef =
      [[self.db collectionWithPath:@"users"] documentWithPath:@"alovelace"];
  // [END doc_reference]
  NSLog(@"%@", alovelaceDocumentRef);
  // [START collection_reference]
  FIRCollectionReference *usersCollectionRef = [self.db collectionWithPath:@"users"];
  // [END collection_reference]
  NSLog(@"%@", usersCollectionRef);
  // [START subcollection_reference]
  FIRDocumentReference *messageRef =
      [[[[self.db collectionWithPath:@"rooms"] documentWithPath:@"roomA"]
      collectionWithPath:@"messages"] documentWithPath:@"message1"];
  // [END subcollection_reference]
  NSLog(@"%@", messageRef);

  // [START path_reference]
  FIRDocumentReference *aLovelaceDocumentReference =
      [self.db documentWithPath:@"users/alovelace"];
  // [END path_reference]
  NSLog(@"%@", aLovelaceDocumentReference);
}

// =======================================================================================
// ========= https://firebase.google.com/preview/firestore/client/save-data ==============
// =======================================================================================

- (void)setDocument {
  // [START set_document]
  // Add a new document in collection "cities" with ID "DC"
  [[[self.db collectionWithPath:@"cities"] documentWithPath:@"DC"] setData:@{
    @"name": @"Washington D.C",
    @"weather": @"politically stormy"
  } completion:^(NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"Error writing document: %@", error);
    } else {
      NSLog(@"Document successfully written!");
    }
  }];
  // [END set_document]
}

- (void)dataTypes {
  // [START data_types]
  NSDictionary *docData = @{
    @"stringExample": @"Hello world!",
    @"booleanExample": @YES,
    @"numberExample": @3.14,
    @"dateExample": [NSDate date],
    @"arrayExample": @[@5, @YES, @"hello"],
    @"nullExample": [NSNull null],
    @"objectExample": @{
      @"a": @5,
      @"b": @{
        @"nested": @"foo"
      }
    }
  };

  [[[self.db collectionWithPath:@"data"] documentWithPath:@"one"] setData:docData
      completion:^(NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Error writing document: %@", error);
        } else {
          NSLog(@"Document successfully written!");
        }
      }];
  // [END data_types]
}

- (void)setData {
  // [START set_data]
  [[[self.db collectionWithPath:@"cities"] documentWithPath:@"new-city-id"]
      setData:@{ @"name": @"Beijing" }];
  // [END set_data]
}

- (void)addDocument {
  // [START add_document]
  // Add a new document with a generated id.
  __block FIRDocumentReference *ref =
      [[self.db collectionWithPath:@"cities"] addDocumentWithData:@{
        @"name": @"Denver",
        @"weather": @"rocky"
      } completion:^(NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Error adding document: %@", error);
        } else {
          NSLog(@"Document added with ID: %@", ref.documentID);
        }
      }];
  // [END add_document]
}

- (void)newDocument {
  // [START new_document]
  FIRDocumentReference *newCityRef = [[self.db collectionWithPath:@"cities"] documentWithAutoID];
  // later...
  [newCityRef setData:@{ /* ... */ }];
  // [END new_document]
}

- (void)updateDocument {
  // [START update_document]
  FIRDocumentReference *washingtonRef =
      [[self.db collectionWithPath:@"cities"] documentWithPath:@"DC"];
  // Set the "isCapital" field of the city 'DC'
  [washingtonRef updateData:@{
    @"isCapital": @YES
  } completion:^(NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"Error updating document: %@", error);
    } else {
      NSLog(@"Document successfully updated");
    }
  }];
  // [END update_document]
}

- (void)createIfMissing {
  // [START create_if_missing]
  // Update the population, creating the document if it does not exist.
  FIRUpdateOptions *createIfMissing = [[FIRUpdateOptions options] createIfMissing:YES];
  [[[self.db collectionWithPath:@"cities"] documentWithPath:@"Beijing"]
       updateData:@{ @"isCapital": @YES }
       options:createIfMissing
       completion:^(NSError * _Nullable error) {
         // ...
       }];
  // [END create_if_missing]
}

- (void)updateDocumentNested {
  // [START update_document_nested]
  // Create an initial document to update.
  FIRDocumentReference *frankDocRef =
      [[self.db collectionWithPath:@"users"] documentWithPath:@"frank"];
  [frankDocRef setData:@{
    @"name": @"Frank",
    @"favorites": @{
      @"food": @"Pizza",
      @"color": @"Blue",
      @"subject": @"recess"
    },
    @"age": @12
  }];
  // To update age and favorite color:
  [frankDocRef updateData:@{
    @"age": @13,
    @"favorites.color": @"Red",
  } completion:^(NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"Error updating document: %@", error);
    } else {
      NSLog(@"Document successfully updated");
    }
  }];
  // [END update_document_nested]
}

- (void)deleteDocument {
  // [START delete_document]
  [[[self.db collectionWithPath:@"cities"] documentWithPath:@"DC"]
      deleteDocumentWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Error removing document: %@", error);
        } else {
          NSLog(@"Document successfully removed!");
        }
  }];
  // [END delete_document]
}

// [START delete_collection]
- (void)deleteCollection:(FIRCollectionReference *)collection
               batchSize:(NSInteger)batchSize
              completion:(void (^)(NSError *))completion {
  // Limit query to avoid out-of-memory errors when deleting large collections.
  // When deleting a collection guaranteed to fit in memory, batching can be avoided entirely.
  [[collection queryLimitedTo:batchSize]
      getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
        if (error != nil) {
          // An error occurred.
          if (completion != nil) { completion(error); }
          return;
        }
        if (snapshot.count == 0) {
          // There's nothing to delete.
          if (completion != nil) { completion(nil); }
          return;
        }

        FIRWriteBatch *batch = [collection.firestore batch];
        for (FIRDocumentSnapshot *document in snapshot.documents) {
          [batch deleteDocument:document.reference];
        }

        [batch commitWithCompletion:^(NSError *batchError) {
          if (batchError != nil) {
            // Stop the deletion process and handle the error. Some elements
            // may have been deleted.
            completion(batchError);
          } else {
            [self deleteCollection:collection batchSize:batchSize completion:completion];
          }
        }];
      }];
}
// [END delete_collection]

- (void)deleteField {
  // [START delete_field]
  [[[self.db collectionWithPath:@"users"] documentWithPath:@"frank"] updateData:@{
    @"age": [FIRFieldValue fieldValueForDelete]
  } completion:^(NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"Error updating document: %@", error);
    } else {
      NSLog(@"Document successfully updated");
    }
  }];
  // [END delete_field]
}

- (void)serverTimestamp {
  // [START server_timestamp]
  [[[self.db collectionWithPath:@"users"] documentWithPath:@"frank"] updateData:@{
    @"lastUpdated": [FIRFieldValue fieldValueForServerTimestamp]
  } completion:^(NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"Error updating document: %@", error);
    } else {
      NSLog(@"Document successfully updated");
    }
  }];
  // [END server_timestamp]
}

- (void)simpleTransaction {
  // [START simple_transaction]
  FIRDocumentReference *sfReference =
      [[self.db collectionWithPath:@"cities"] documentWithPath:@"SF"];
  [self.db runTransactionWithBlock:^id (FIRTransaction *transaction, NSError **errorPointer) {
    FIRDocumentSnapshot *sfDocument = [transaction getDocument:sfReference error:errorPointer];
    if (*errorPointer != nil) { return nil; }

    if (![sfDocument.data[@"population"] isKindOfClass:[NSNumber class]]) {
      *errorPointer = [NSError errorWithDomain:@"AppErrorDomain" code:-1 userInfo:@{
        NSLocalizedDescriptionKey: @"Unable to retreive population from snapshot"
      }];
      return nil;
    }
    NSInteger oldPopulation = [sfDocument.data[@"population"] integerValue];

    [transaction updateData:@{ @"population": @(oldPopulation + 1) } forDocument:sfReference];

    return nil;
  } completion:^(id result, NSError *error) {
    if (error != nil) {
      NSLog(@"Transaction failed: %@", error);
    } else {
      NSLog(@"Transaction successfully committed!");
    }
  }];
  // [END simple_transaction]
}

- (void)transaction {
  // [START transaction]
  FIRDocumentReference *sfReference =
  [[self.db collectionWithPath:@"cities"] documentWithPath:@"SF"];
  [self.db runTransactionWithBlock:^id (FIRTransaction *transaction, NSError **errorPointer) {
    FIRDocumentSnapshot *sfDocument = [transaction getDocument:sfReference error:errorPointer];
    if (*errorPointer != nil) { return nil; }

    if (![sfDocument.data[@"population"] isKindOfClass:[NSNumber class]]) {
      *errorPointer = [NSError errorWithDomain:@"AppErrorDomain" code:-1 userInfo:@{
        NSLocalizedDescriptionKey: @"Unable to retreive population from snapshot"
      }];
      return nil;
    }
    NSInteger population = [sfDocument.data[@"population"] integerValue];

    population++;
    if (population >= 1000000) {
      *errorPointer = [NSError errorWithDomain:@"AppErrorDomain" code:-2 userInfo:@{
        NSLocalizedDescriptionKey: @"Population too big"
      }];
      return @(population);
    }

    [transaction updateData:@{ @"population": @(population) } forDocument:sfReference];

    return nil;
  } completion:^(id result, NSError *error) {
    if (error != nil) {
      NSLog(@"Transaction failed: %@", error);
    } else {
      NSLog(@"Population increased to %@", result);
    }
  }];
  // [END transaction]
}

- (void)writeBatch {
  // [START write_batch]
  // Get new write batch
  FIRWriteBatch *batch = [self.db batch];
  // Set the value of 'NYC'
  FIRDocumentReference *nycRef =
      [[self.db collectionWithPath:@"cities"] documentWithPath:@"NYC"];
  [batch setData:@{} forDocument:nycRef];
  // Update the population of 'SF'
  FIRDocumentReference *sfRef =
      [[self.db collectionWithPath:@"cities"] documentWithPath:@"SF"];
  [batch updateData:@{ @"population": @1000000 } forDocument:sfRef];
  // Delete the city 'LA'
  FIRDocumentReference *laRef =
      [[self.db collectionWithPath:@"cities"] documentWithPath:@"LA"];
  [batch deleteDocument:laRef];
  // Commit the batch
  [batch commitWithCompletion:^(NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"Error writing batch %@", error);
    } else {
      NSLog(@"Batch write succeeded.");
    }
  }];
  // [END write_batch]
}

// =======================================================================================
// ======= https://firebase.google.com/preview/firestore/client/retrieve-data ============
// =======================================================================================

- (void)exampleData {
  // [START example_data]
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  [[citiesRef documentWithPath:@"SF"] setData:@{
    @"name": @"San Francisco",
    @"state": @"CA",
    @"population": @864816
  }];
  [[citiesRef documentWithPath:@"MTV"] setData:@{
    @"name": @"Mountain View",
    @"state": @"CA",
    @"population": @74066
  }];
  [[citiesRef documentWithPath:@"DEN"] setData:@{
    @"name": @"Denver",
    @"state": @"CA",
    @"population": @600158
  }];
  [[citiesRef documentWithPath:@"DC"] setData:@{
    @"name": @"Washington D.C.",
    @"population": @672228
  }];
  // [END example_data]
}

- (void)getDocument {
  // [START get_document]
  FIRDocumentReference *docRef =
      [[self.db collectionWithPath:@"cities"] documentWithPath:@"SF"];
  [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
    if (snapshot != nil) {
      NSLog(@"Document data: %@", snapshot.data);
    } else {
      NSLog(@"Document does not exist");
    }
  }];
  // RESULT:
  // Document data: ["state": CA, "name": San Francisco, "population": 864816]
  // [END get_document]
}

- (void)customClassGetDocument {
  // [START custom_type]
  FIRDocumentReference *docRef =
  [[self.db collectionWithPath:@"cities"] documentWithPath:@"Beijing"];
  [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
    FSTCity *city = [[FSTCity alloc] initWithDictionary:snapshot.data];
    if (city != nil) {
      NSLog(@"City: %@", city);
    } else {
      NSLog(@"Document does not exist");
    }
  }];
  // [END custom_type]
}

- (void)listenDocument {
  // [START listen_document]
  [[[self.db collectionWithPath:@"cities"] documentWithPath:@"SF"]
      addSnapshotListener:^(FIRDocumentSnapshot *snapshot, NSError *error) {
        if (snapshot == nil) {
          NSLog(@"Error fetching document: %@", error);
          return;
        }
        NSLog(@"Current data: %@", snapshot.data);
      }];
  // After 2 seconds, make an update so our listener will fire again.
  dispatch_time_t deadline = dispatch_time(0, 2 * NSEC_PER_SEC);
  dispatch_after(deadline, dispatch_get_main_queue(), ^{
    [[[self.db collectionWithPath:@"cities"] documentWithPath:@"SF"] updateData:@{
      @"population": @999999
    }];
  });
  // RESULT:
  // Current data: ["state": CA, "name": San Francisco, "population": 864816]
  //
  // Current data: ["state": CA, "name": San Francisco, "population": 999999]
  // Current data: ["state": CA, "name": San Francisco, "population": 999999]
  // [END listen_document]
}

- (void)listenDocumentLocal {
  // [START listen_document_local]
  [[[self.db collectionWithPath:@"cities"] documentWithPath:@"SF"]
      addSnapshotListener:^(FIRDocumentSnapshot *snapshot, NSError *error) {
        if (snapshot == nil) {
          NSLog(@"Error fetching document: %@", error);
          return;
        }
        NSString *source = snapshot.metadata.hasPendingWrites ? @"Local" : @"Server";
        NSLog(@"%@ data: %@", source, snapshot.data);
      }];
  // After 2 seconds, make an update so our listener will fire again.
  dispatch_time_t deadline = dispatch_time(0, 2 * NSEC_PER_SEC);
  dispatch_after(deadline, dispatch_get_main_queue(), ^{
    [[[self.db collectionWithPath:@"cities"] documentWithPath:@"SF"] updateData:@{
      @"population": @1000000
    }];
  });
  // RESULT:
  // Server data: ["state": CA, "name": San Francisco, "population": 999999]
  // Local data: ["state": CA, "name": San Francisco, "population": 1000000]
  // Server data: ["state": CA, "name": San Francisco, "population": 1000000]
  // [END listen_document_local]
}

- (void)getMultiple {
  // [START get_multiple]
  [[[self.db collectionWithPath:@"cities"] queryWhereField:@"state" isEqualTo:@"CA"]
      getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
        if (error != nil) {
          NSLog(@"Error getting documents: %@", error);
        } else {
          for (FIRDocumentSnapshot *document in snapshot.documents) {
            NSLog(@"%@ => %@", document.documentID, document.data);
          }
        }
      }];
  // RESULT:
  // MTV => ["state": CA, "name": Mountain View, "population": 74066]
  // SF => ["state": CA, "name": San Francisco, "population": 864816]
  // [END get_multiple]
}

- (void)getMultipleAll {
  // [START get_multiple_all]
  [[self.db collectionWithPath:@"cities"]
      getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
        if (error != nil) {
          NSLog(@"Error getting documents: %@", error);
        } else {
          for (FIRDocumentSnapshot *document in snapshot.documents) {
            NSLog(@"%@ => %@", document.documentID, document.data);
          }
        }
      }];
  // RESULT:
  // DC => ["population": 672228, "name": Washington, D.C.]
  // DEN => ["state": CO, "name": Denver, "population": 600158]
  // MTV => ["state": CA, "name": Mountain View, "population": 74066]
  // SF => ["state": CA, "name": San Francisco, "population": 864816]
  // [END get_multiple_all]
}

- (void)listenMultiple {
  // [START listen_multiple]
  [[[self.db collectionWithPath:@"cities"] queryWhereField:@"state" isEqualTo:@"CA"]
      addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error) {
        if (snapshot == nil) {
          NSLog(@"Error fetching documents: %@", error);
          return;
        }
        NSMutableArray *cities = [NSMutableArray array];
        for (FIRDocumentSnapshot *document in snapshot.documents) {
          [cities addObject:document.data[@"name"]];
        }
        NSLog(@"Current cities in CA: %@", cities);
      }];
  // After 2 seconds, make an update so our listener will fire again.
  dispatch_time_t deadline = dispatch_time(0, 2 * NSEC_PER_SEC);
  dispatch_after(deadline, dispatch_get_main_queue(), ^{
    [[[self.db collectionWithPath:@"cities"] documentWithPath:@"LA"] setData:@{
      @"name": @"Los Angeles",
      @"state": @"CA",
      @"population": @403094
    }];
  });
  // RESULT:
  // Current cities in CA: [Mountain View, San Francisco]
  //
  // Current cities in CA: [Los Angeles, Mountain View, San Francisco]
  // [END listen_multiple]
}

- (void)listenDiffs {
  // [START listen_diffs]
  [[[self.db collectionWithPath:@"cities"] queryWhereField:@"state" isEqualTo:@"CA"]
      addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error) {
        if (snapshot == nil) {
          NSLog(@"Error fetching documents: %@", error);
          return;
        }
        for (FIRDocumentChange *diff in snapshot.documentChanges) {
          if (diff.type == FIRDocumentChangeTypeAdded) {
            NSLog(@"New city: %@", diff.document.data);
          }
          if (diff.type == FIRDocumentChangeTypeModified) {
            NSLog(@"Modified city: %@", diff.document.data);
          }
          if (diff.type == FIRDocumentChangeTypeRemoved) {
            NSLog(@"Removed city: %@", diff.document.data);
          }
        }
      }];
  // After 2 seconds, let's delete LA
  dispatch_time_t deadline = dispatch_time(0, 2 * NSEC_PER_SEC);
  dispatch_after(deadline, dispatch_get_main_queue(), ^{
    [[[self.db collectionWithPath:@"cities"] documentWithPath:@"LA"] deleteDocument];
  });
  // RESULT:
  // New city: ["state": CA, "name": Los Angeles, "population": 4030904]
  // New city: ["state": CA, "name": Mountain View, "population": 74066]
  // New city: ["state": CA, "name": San Francisco, "population": 864816]
  // Removed city: ["state": CA, "name": Los Angeles, "population": 4030904]
  // [END listen_diffs]
}

- (void)listenState {
  // [START listen_state]
  [[[self.db collectionWithPath:@"cities"] queryWhereField:@"state" isEqualTo:@"CA"]
      addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error) {
        if (snapshot == nil) {
          NSLog(@"Error fetching documents: %@", error);
          return;
        }
        for (FIRDocumentChange *diff in snapshot.documentChanges) {
          if (diff.type == FIRDocumentChangeTypeAdded) {
            NSLog(@"New city: %@", diff.document.data);
          }
          if (!snapshot.metadata.isFromCache) {
            NSLog(@"Synced with server state.");
          }
        }
      }];
  // RESULT:
  // New city: ["state": CA, "name": Mountain View, "population": 74066]
  // New city: ["state": CA, "name": San Francisco, "population": 864816]
  // Got initial state.
  // [END listen_state]
}

- (void)detachListener {
  // [START detach_listener]
  id<FIRListenerRegistration> listener = [[self.db collectionWithPath:@"cities"]
      addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error) {
        // ...
  }];

  // ...

  // Stop listening to changes
  [listener remove];
  // [END detach_listener]
}

- (void)handleListenErrors {
  // [START handle_listen_errors]
  [[self.db collectionWithPath:@"cities"]
      addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error) {
        if (error != nil) {
          NSLog(@"Error retreving collection: %@", error);
        }
      }];
  // [END handle_listen_errors]
}

// =======================================================================================
// ======== https://firebase.google.com/preview/firestore/client/query-data ==============
// =======================================================================================

- (void)simpleQueries {
  // [START simple_queries]
  // Create a reference to the cities collection
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  // Create a query against the collection.
  FIRQuery *query = [citiesRef queryWhereField:@"state" isEqualTo:@"CA"];
  // [END simple_queries]
  NSLog(@"%@", query);
}

- (void)exampleFilters {
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  // [START example_filters]
  [citiesRef queryWhereField:@"state" isEqualTo:@"CA"];
  [citiesRef queryWhereField:@"population" isLessThan:@100000];
  [citiesRef queryWhereField:@"name" isGreaterThanOrEqualTo:@"San Francisco"];
  // [END example_filters]
}

- (void)onlyCapitals {
  // [START only_capitals]
  FIRQuery *capitalCities =
      [[self.db collectionWithPath:@"cities"] queryWhereField:@"capital" isEqualTo:@YES];
  // [END only_capitals]
  NSLog(@"%@", capitalCities);
}

- (void)chainFilters {
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  // [START chain_filters]
  [[citiesRef queryWhereField:@"state" isEqualTo:@"CO"]
      queryWhereField:@"name" isGreaterThanOrEqualTo:@"Denver"];
  [[citiesRef queryWhereField:@"state" isEqualTo:@"CA"]
      queryWhereField:@"population" isLessThan:@1000000];
  // [END chain_filters]
}

- (void)validRangeFilters {
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  // [START valid_range_filters]
  [[citiesRef queryWhereField:@"state" isGreaterThanOrEqualTo:@"CA"]
      queryWhereField:@"state" isLessThanOrEqualTo:@"IN"];
  [[citiesRef queryWhereField:@"state" isEqualTo:@"CA"]
      queryWhereField:@"population" isGreaterThan:@1000000];
  // [END valid_range_filters]
}

- (void)invalidRangeFilters {
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  // [START invalid_range_filters]
  [[citiesRef queryWhereField:@"state" isGreaterThanOrEqualTo:@"CA"]
      queryWhereField:@"population" isGreaterThan:@1000000];
  // [END invalid_range_filters]
}

- (void)orderAndLimit {
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  // [START order_and_limit]
  [[citiesRef queryOrderedByField:@"name"] queryLimitedTo:3];
  // [END order_and_limit]
}

- (void)orderAndLimitDesc {
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  // [START order_and_limit_desc]
  [[citiesRef queryOrderedByField:@"name" descending:YES] queryLimitedTo:3];
  // [END order_and_limit_desc]
}

- (void)orderMultiple {
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  // [START order_multiple]
  [[citiesRef queryOrderedByField:@"state"] queryOrderedByField:@"population" descending:YES];
  // [END order_multiple]
}

- (void)filterAndOrder {
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  // [START filter_and_order]
  [[[citiesRef queryWhereField:@"population" isGreaterThan:@100000]
      queryOrderedByField:@"population"]
      queryLimitedTo:2];
  // [END filter_and_order]
}

- (void)validFilterAndOrder {
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  // [START valid_filter_and_order]
  [[citiesRef queryWhereField:@"population" isGreaterThan:@100000]
      queryOrderedByField:@"population"];
  // [END valid_filter_and_order]
}

- (void)invalidFilterAndOrder {
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  // [START invalid_filter_and_order]
  [[citiesRef queryWhereField:@"population" isGreaterThan:@100000] queryOrderedByField:@"state"];
  // [END invalid_filter_and_order]
}

// =======================================================================================
// ====== https://firebase.google.com/preview/firestore/client/enable-offline ============
// =======================================================================================

- (void)enableOffline {
  // [START enable_offline]
  FIRFirestoreSettings *settings = [[FIRFirestoreSettings alloc] init];
  settings.persistenceEnabled = YES;

  // Any additional options
  // ...

  // Enable offline data persistence
  FIRFirestore *db = [FIRFirestore firestore];
  db.settings = settings;
  // [END enable_offline]
}

- (void)listenToOffline {
  FIRFirestore *db = self.db;
  // [START listen_to_offline]
  // Listen to metadata updates to receive a server snapshot even if
  // the data is the same as the cached data.
  FIRQueryListenOptions *options = [FIRQueryListenOptions options];
  [options includeQueryMetadataChanges:YES];
  [[[db collectionWithPath:@"cities"] queryWhereField:@"state" isEqualTo:@"CA"]
      addSnapshotListenerWithOptions:options
      listener:^(FIRQuerySnapshot *snapshot, NSError *error) {
        if (snapshot == nil) {
          NSLog(@"Error retreiving snapshot: %@", error);
          return;
        }
        for (FIRDocumentChange *diff in snapshot.documentChanges) {
          if (diff.type == FIRDocumentChangeTypeAdded) {
            NSLog(@"New city: %@", diff.document.data);
          }
        }

        NSString *source = snapshot.metadata.isFromCache ? @"local cache" : @"server";
        NSLog(@"Metadata: Data fetched from %@", source);
      }];
  // RESULT:
  // New city: ["state": CA, "name": Mountain View, "population": 74066]
  // New city: ["state": CA, "name": San Francisco, "population": 864816]
  // Metadata: Data fetched from local cache
  // Metadata: Data fetched from server (if online)
  // [END listen_to_offline]
}

// =======================================================================================
// ====== https://firebase.google.com/preview/firestore/client/cursors ===================
// =======================================================================================

- (void)simpleCursor {
  FIRFirestore *db = self.db;

  // [START cursor_greater_than]
  // Get all cities with population over one million, ordered by population.
  [[[db collectionWithPath:@"cities"]
      queryOrderedByField:@"population"]
      queryStartingAtValues:@[ @1000000 ]];
  // [END cursor_greater_than]
  // [START cursor_less_than]
  // Get all cities with population less than one million, ordered by population.
  [[[db collectionWithPath:@"cities"]
      queryOrderedByField:@"population"]
      queryEndingAtValues:@[ @1000000 ]];
  // [END cursor_less_than]
}

- (void)snapshotCursor {
  FIRFirestore *db = self.db;

  // [START snapshot_cursor]
  [[[db collectionWithPath:@"cities"] documentWithPath:@"SF"]
      addSnapshotListener:^(FIRDocumentSnapshot *snapshot, NSError *error) {
        if (snapshot == nil) {
          NSLog(@"Error retreiving cities: %@", error);
          return;
        }
        // Get all cities with a population greater than or equal to San Francisco.
        FIRQuery *sfSizeOrBigger = [[[db collectionWithPath:@"cities"]
            queryOrderedByField:@"population"]
            queryStartingAtDocument:snapshot];
      }];
  // [END snapshot_cursor]
}

- (void)paginate {
  FIRFirestore *db = self.db;

  // [START paginate]
  FIRQuery *first = [[[db collectionWithPath:@"cities"]
      queryOrderedByField:@"population"]
      queryLimitedTo:25];
  [first addSnapshotListener:^(FIRQuerySnapshot *snapshot, NSError *error) {
    if (snapshot == nil) {
      NSLog(@"Error retreiving cities: %@", error);
      return;
    }
    if (snapshot.documents.count == 0) { return; }
    FIRDocumentSnapshot *lastSnapshot = snapshot.documents.lastObject;

    // Construct a new query starting after this document,
    // retreiving the next 25 cities.
    FIRQuery *next = [[[db collectionWithPath:@"cities"]
        queryOrderedByField:@"population"]
        queryStartingAfterDocument:lastSnapshot];
    // Use the query for pagination.
    // ...
  }];
  // [END paginate]
}

- (void)multiCursor {
  FIRFirestore *db = self.db;

  // [START multi_cursor]
  // Will return all Springfields
  [[[[db collectionWithPath:@"cities"]
      queryOrderedByField:@"name"]
      queryOrderedByField:@"state"]
      queryStartingAtValues:@[ @"Springfield" ]];
  // Will return "Springfield, Missouri" and "Springfield, Wisconsin"
  [[[[db collectionWithPath:@"cities"]
     queryOrderedByField:@"name"]
     queryOrderedByField:@"state"]
     queryStartingAtValues:@[ @"Springfield", @"Missouri" ]];
  // [END multi_cursor]
}

@end
