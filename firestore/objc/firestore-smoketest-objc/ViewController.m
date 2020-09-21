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

@import FirebaseCore;
@import FirebaseFirestore;

#import "ViewController.h"

@interface FSTCity : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *state;
@property (nonatomic, readonly) NSString *country;
@property (nonatomic, readonly) BOOL capital;
@property (nonatomic, readonly) NSInteger population;

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

    if (dict[@"state"] != nil && [dict[@"state"] isKindOfClass:[NSString class]]) {
      _state = [dict[@"state"] copy];
    }

    if (dict[@"country"] != nil && [dict[@"country"] isKindOfClass:[NSString class]]) {
      _country = [dict[@"country"] copy];
    }

    if (dict[@"capital"] != nil) {
      _capital = [dict[@"capital"] boolValue];
    }

    if (dict[@"population"] != nil) {
      _population = [dict[@"population"] integerValue];
    }
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

  self.db = [FIRFirestore firestore];
}

// =======================================================================================
// ======== https://firebase.google.com/preview/firestore/client/quickstart ==============
// =======================================================================================

- (void)setupCacheSize {
    // [START fs_setup_cache]
    FIRFirestoreSettings *settings = [FIRFirestore firestore].settings;
    settings.cacheSizeBytes = kFIRFirestoreCacheSizeUnlimited;
    [FIRFirestore firestore].settings = settings;
    // [END fs_setup_cache]
}

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
  // Add a new document in collection "cities"
  [[[self.db collectionWithPath:@"cities"] documentWithPath:@"LA"] setData:@{
    @"name": @"Los Angeles",
    @"state": @"CA",
    @"country": @"USA"
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
    @"dateExample": [FIRTimestamp timestampWithDate:[NSDate date]],
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
  NSDictionary *data = @{ @"name": @"Beijing" };
  // [START set_data]
  [[[self.db collectionWithPath:@"cities"] documentWithPath:@"new-city-id"]
      setData:data];
  // [END set_data]
}

- (void)addDocument {
  // [START add_document]
  // Add a new document with a generated id.
  __block FIRDocumentReference *ref =
      [[self.db collectionWithPath:@"cities"] addDocumentWithData:@{
        @"name": @"Tokyo",
        @"country": @"Japan"
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
  // Set the "capital" field of the city
  [washingtonRef updateData:@{
    @"capital": @YES
  } completion:^(NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"Error updating document: %@", error);
    } else {
      NSLog(@"Document successfully updated");
    }
  }];
  // [END update_document]
}

- (void)updateDocumentArray {
  // [START update_document_array]
  FIRDocumentReference *washingtonRef =
      [[self.db collectionWithPath:@"cities"] documentWithPath:@"DC"];

  // Atomically add a new region to the "regions" array field.
  [washingtonRef updateData:@{
    @"regions": [FIRFieldValue fieldValueForArrayUnion:@[@"greater_virginia"]]
  }];

  // Atomically remove a new region to the "regions" array field.
  [washingtonRef updateData:@{
    @"regions": [FIRFieldValue fieldValueForArrayRemove:@[@"east_coast"]]
  }];
  // [END update_document_array]
}

- (void)updateDocumentIncrement {
  // [START update_document_increment]
  FIRDocumentReference *washingtonRef =
      [[self.db collectionWithPath:@"cities"] documentWithPath:@"DC"];

  // Atomically increment the population of the city by 50.
  // Note that increment() with no arguments increments by 1.
  [washingtonRef updateData:@{
    @"population": [FIRFieldValue fieldValueForIntegerIncrement:50]
  }];
  // [END update_document_increment]
}

- (void)createIfMissing {
  // [START create_if_missing]
  // Write to the document reference, merging data with existing
  // if the document already exists
  [[[self.db collectionWithPath:@"cities"] documentWithPath:@"BJ"]
       setData:@{ @"capital": @YES }
       merge:YES
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
  [[[self.db collectionWithPath:@"cities"] documentWithPath:@"BJ"] updateData:@{
    @"capital": [FIRFieldValue fieldValueForDelete]
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
  [[[self.db collectionWithPath:@"objects"] documentWithPath:@"some-id"] updateData:@{
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

- (void)serverTimestampOptions {
  // [START server_timestamp_options]
  FIRDocumentReference *docRef =
      [[self.db collectionWithPath:@"objects"] documentWithPath:@"some-id"];

  // Perform an update followed by an immediate read without waiting for the update to complete.
  // Due to the snapshot options we will get two results: one with an estimated timestamp and
  // one with the resolved server timestamp.
  [docRef updateData:@{
    @"timestamp": [FIRFieldValue fieldValueForServerTimestamp],
  }];
  [docRef addSnapshotListener:^(FIRDocumentSnapshot *snapshot, NSError *error) {
    NSDictionary *data = [snapshot dataWithServerTimestampBehavior:FIRServerTimestampBehaviorEstimate];
    NSDate *timestamp = data[@"timestamp"];
    NSLog(@"Timestamp: %@, pending: %@",
          timestamp,
          snapshot.metadata.hasPendingWrites ? @"YES" : @"NO");
  }];
  // [END server_timestamp_options]
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

    // Note: this could be done without a transaction
    //       by updating the population using FieldValue.increment()
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
    @"country": @"USA",
    @"capital": @(NO),
    @"population": @860000,
    @"regions": @[@"west_coast", @"norcal"]
  }];
  [[citiesRef documentWithPath:@"LA"] setData:@{
    @"name": @"Los Angeles",
    @"state": @"CA",
    @"country": @"USA",
    @"capital": @(NO),
    @"population": @3900000,
    @"regions": @[@"west_coast", @"socal"]
  }];
  [[citiesRef documentWithPath:@"DC"] setData:@{
    @"name": @"Washington D.C.",
    @"country": @"USA",
    @"capital": @(YES),
    @"population": @680000,
    @"regions": @[@"east_coast"]
  }];
  [[citiesRef documentWithPath:@"TOK"] setData:@{
    @"name": @"Tokyo",
    @"country": @"Japan",
    @"capital": @(YES),
    @"population": @9000000,
    @"regions": @[@"kanto", @"honshu"]
  }];
  [[citiesRef documentWithPath:@"BJ"] setData:@{
    @"name": @"Beijing",
    @"country": @"China",
    @"capital": @(YES),
    @"population": @21500000,
    @"regions": @[@"jingjinji", @"hebei"]
  }];
  // [END example_data]
}

- (void)exampleDataCollectionGroup {
    // [START fs_collection_group_query_data_setup]
    FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];

    NSDictionary *data = @{@"name": @"Golden Gate Bridge", @"type": @"bridge"};
    [[[citiesRef documentWithPath:@"SF"] collectionWithPath:@"landmarks"] addDocumentWithData:data];

    data = @{@"name": @"Legion of Honor", @"type": @"museum"};
    [[[citiesRef documentWithPath:@"SF"] collectionWithPath:@"landmarks"] addDocumentWithData:data];

    data = @{@"name": @"Griffith Park", @"type": @"park"};
    [[[citiesRef documentWithPath:@"LA"] collectionWithPath:@"landmarks"] addDocumentWithData:data];

    data = @{@"name": @"The Getty", @"type": @"museum"};
    [[[citiesRef documentWithPath:@"LA"] collectionWithPath:@"landmarks"] addDocumentWithData:data];

    data = @{@"name": @"Lincoln Memorial", @"type": @"memorial"};
    [[[citiesRef documentWithPath:@"DC"] collectionWithPath:@"landmarks"] addDocumentWithData:data];

    data = @{@"name": @"National Air and Space Museum", @"type": @"museum"};
    [[[citiesRef documentWithPath:@"DC"] collectionWithPath:@"landmarks"] addDocumentWithData:data];

    data = @{@"name": @"Ueno Park", @"type": @"park"};
    [[[citiesRef documentWithPath:@"TOK"] collectionWithPath:@"landmarks"] addDocumentWithData:data];

    data = @{@"name": @"National Museum of Nature and Science", @"type": @"museum"};
    [[[citiesRef documentWithPath:@"TOK"] collectionWithPath:@"landmarks"] addDocumentWithData:data];

    data = @{@"name": @"Jingshan Park", @"type": @"park"};
    [[[citiesRef documentWithPath:@"BJ"] collectionWithPath:@"landmarks"] addDocumentWithData:data];

    data = @{@"name": @"Beijing Ancient Observatory", @"type": @"museum"};
    [[[citiesRef documentWithPath:@"BJ"] collectionWithPath:@"landmarks"] addDocumentWithData:data];
    // [END fs_collection_group_query_data_setup]
}

- (void)getDocument {
  // [START get_document]
  FIRDocumentReference *docRef =
      [[self.db collectionWithPath:@"cities"] documentWithPath:@"SF"];
  [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
    if (snapshot.exists) {
      // Document data may be nil if the document exists but has no keys or values.
      NSLog(@"Document data: %@", snapshot.data);
    } else {
      NSLog(@"Document does not exist");
    }
  }];
  // [END get_document]
}

- (void)getDocumentWithOptions {
  // [START get_document_options]
  FIRDocumentReference *docRef =
  [[self.db collectionWithPath:@"cities"] documentWithPath:@"SF"];

  // Force the SDK to fetch the document from the cache. Could also specify
  // FIRFirestoreSourceServer or FIRFirestoreSourceDefault.
  [docRef getDocumentWithSource:FIRFirestoreSourceCache
                     completion:^(FIRDocumentSnapshot *snapshot, NSError *error) {
    if (snapshot != NULL) {
      // The document data was found in the cache.
      NSLog(@"Cached document data: %@", snapshot.data);
    } else {
      // The document data was not found in the cache.
      NSLog(@"Document does not exist in cache: %@", error);
    }
  }];
  // [END get_document_options]
}

- (void)customClassGetDocument {
  // [START custom_type]
  FIRDocumentReference *docRef =
  [[self.db collectionWithPath:@"cities"] documentWithPath:@"BJ"];
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
  // [END listen_document_local]
}

- (void)listenWithMetadata {
  // [START listen_with_metadata]
  // Listen for metadata changes.
  [[[self.db collectionWithPath:@"cities"] documentWithPath:@"SF"]
      addSnapshotListenerWithIncludeMetadataChanges:YES
                                           listener:^(FIRDocumentSnapshot *snapshot, NSError *error) {
     // ...
  }];
  // [END listen_with_metadata]
}

- (void)getMultiple {
  // [START get_multiple]
  [[[self.db collectionWithPath:@"cities"] queryWhereField:@"capital" isEqualTo:@(YES)]
      getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
        if (error != nil) {
          NSLog(@"Error getting documents: %@", error);
        } else {
          for (FIRDocumentSnapshot *document in snapshot.documents) {
            NSLog(@"%@ => %@", document.documentID, document.data);
          }
        }
      }];
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
  // [START simple_query_not_equal]
  query = [citiesRef queryWhereField:@"capital" isNotEqualTo:@NO];
  // [END simple_query_not_equal]
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

- (void)arrayContainsFilter {
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];
  // [START array_contains_filter]
  [citiesRef queryWhereField:@"state" arrayContains:@"west_coast"];
  // [END array_contains_filter]
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
  [[citiesRef queryWhereField:@"population" isGreaterThan:@100000] queryOrderedByField:@"country"];
  // [END invalid_filter_and_order]
}

- (void)arrayContainsAnyQueries {
  // [START array_contains_any_filter]
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];

  [citiesRef queryWhereField:@"regions" arrayContainsAny:@[@"west_coast", @"east_coast"]];
  // [END array_contains_any_filter]
}

- (void)inQueries {
  // [START in_filter]
  FIRCollectionReference *citiesRef = [self.db collectionWithPath:@"cities"];

  [citiesRef queryWhereField:@"country" in:@[@"USA", @"Japan"]];
  // [END in_filter]

  // [START in_filter_with_array]
  [citiesRef queryWhereField:@"regions" in:@[@[@"west_coast"], @[@"east_coast"]]];
  // [END in_filter_with_array]

  // [START not_in_filter]
  [citiesRef queryWhereField:@"country" notIn:@[@"USA", @"Japan"]];
  // [END not_in_filter]
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
  [[[db collectionWithPath:@"cities"] queryWhereField:@"state" isEqualTo:@"CA"]
      addSnapshotListenerWithIncludeMetadataChanges:YES
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
  // [END listen_to_offline]
}

- (void)toggleOffline {
  // [START disable_network]
  [[FIRFirestore firestore] disableNetworkWithCompletion:^(NSError *_Nullable error) {
    // Do offline actions
    // ...
  }];
  // [END disable_network]

  // [START enable_network]
  [[FIRFirestore firestore] enableNetworkWithCompletion:^(NSError *_Nullable error) {
    // Do online actions
    // ...
  }];
  // [END enable_network]
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
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

#pragma clang diagnostic pop

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

- (void)collectionGroupQuery {
    // [START fs_collection_group_query]
    [[[self.db collectionGroupWithID:@"landmarks"] queryWhereField:@"type" isEqualTo:@"museum"]
        getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
        // [START_EXCLUDE]
        // [END_EXCLUDE]
    }];
    // [END fs_collection_group_query]
}

- (void)emulatorSettings {
    // [START fs_emulator_connect]
    FIRFirestoreSettings *settings = [FIRFirestore firestore].settings;
    settings.host = @"localhost:8080";
    settings.sslEnabled = false;
    [FIRFirestore firestore].settings = settings;
    // [END fs_emulator_connect]
}

@end
