//
//  FIRSolutionsBundleViewController.m
//  firestore-smoketest-objc
//
//  Created by Morgan Chen on 3/25/21.
//  Copyright © 2021 Firebase. All rights reserved.
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

// Loads a remote bundle from the provided url.
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

@end
