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

@import FirebaseFirestore;

#import "FIRSolutionsBundleViewController.h"

@interface FIRSolutionsBundleViewController ()

@end

@implementation FIRSolutionsBundleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// [START fs_bundle_load]
// Utility function for errors when loading bundles.
- (NSError *)bundleLoadErrorWithReason:(NSString *)reason {
  return [NSError errorWithDomain:@"FIRSampleErrorDomain"
                             code:0
                         userInfo:@{NSLocalizedFailureReasonErrorKey: reason}];
}

// Loads a remote bundle from the provided url.
- (void)fetchRemoteBundleForFirestore:(FIRFirestore *)firestore
                              fromURL:(NSURL *)url
                           completion:(void (^)(FIRLoadBundleTaskProgress *_Nullable,
                                                NSError *_Nullable))completion {
  NSInputStream *inputStream = [NSInputStream inputStreamWithURL:url];
  if (inputStream == nil) {
    // Unable to create input stream.
    NSError *error =
        [self bundleLoadErrorWithReason:
            [NSString stringWithFormat:@"Unable to create stream from the given url: %@", url]];
    completion(nil, error);
    return;
  }

  [firestore loadBundleStream:inputStream
                   completion:^(FIRLoadBundleTaskProgress * _Nullable progress,
                                NSError * _Nullable error) {
    if (progress == nil) {
      completion(nil, error);
      return;
    }

    if (progress.state == FIRLoadBundleTaskStateSuccess) {
      completion(progress, nil);
    } else {
      NSError *concreteError =
          [self bundleLoadErrorWithReason:
              [NSString stringWithFormat:
                  @"Expected bundle load to be completed, but got %ld instead",
                  (long)progress.state]];
      completion(nil, concreteError);
    }
    completion(nil, nil);
  }];
}

// Loads a bundled query.
- (void)loadQueryNamed:(NSString *)queryName
   fromRemoteBundleURL:(NSURL *)url
         withFirestore:(FIRFirestore *)firestore
            completion:(void (^)(FIRQuery *_Nullable, NSError *_Nullable))completion {
  [self fetchRemoteBundleForFirestore:firestore
                              fromURL:url
                           completion:^(FIRLoadBundleTaskProgress *progress, NSError *error) {
    if (error != nil) {
      completion(nil, error);
      return;
    }

    [firestore getQueryNamed:queryName completion:^(FIRQuery *query) {
      if (query == nil) {
        NSString *errorReason =
            [NSString stringWithFormat:@"Could not find query named %@", queryName];
        NSError *error = [self bundleLoadErrorWithReason:errorReason];
        completion(nil, error);
        return;
      }
      completion(query, nil);
    }];
  }];
}

- (void)runStoriesQuery {
  NSString *queryName = @"latest-stories-query";
  FIRFirestore *firestore = [FIRFirestore firestore];
  NSURL *bundleURL = [NSURL URLWithString:@"https://example.com/createBundle"];
  [self loadQueryNamed:queryName
   fromRemoteBundleURL:bundleURL
         withFirestore:firestore
            completion:^(FIRQuery *query, NSError *error) {
    // Handle query results
  }];
}
// [END fs_bundle_load]

// [START fs_simple_bundle_load]
// Load a bundle from a local URL.
- (void)loadBundleFromBundleURL:(NSURL *)bundleURL {
  FIRFirestore *firestore = [FIRFirestore firestore];
  NSError *error;
  NSData *data = [NSData dataWithContentsOfURL:bundleURL options:kNilOptions error:&error];
  if (error != nil) {
    NSLog(@"%@", error);
    return;
  }
  [firestore loadBundle:data];
}
// [END fs_simple_bundle_load]

// [START fs_named_query]
- (void)runNamedQuery {
  FIRFirestore *firestore = [FIRFirestore firestore];
  [firestore getQueryNamed:@"coll-query" completion:^(FIRQuery *_Nullable query) {
    [query getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot, NSError *error) {
      // ...
    }];
  }];
}
// [END fs_named_query]

// [START bundle_observe_progress]
- (void)observeProgressOfLoadBundleTask:(FIRLoadBundleTask *)loadBundleTask {
  NSInteger handle = [loadBundleTask addObserver:^(FIRLoadBundleTaskProgress *progress) {
    NSLog(@"Loaded %ld bytes out of %ld total",
          (long)progress.bytesLoaded,
          (long)progress.totalBytes);
  }];

  // ...
  [loadBundleTask removeObserverWithHandle:handle];
}
// [END bundle_observe_progress]

@end
