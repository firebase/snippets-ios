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

@import Firebase;

#import "FIRSolutionArraysViewController.h"

@interface FIRSolutionArraysViewController ()
@property (nonatomic, readonly) FIRFirestore *db;
@end

@implementation FIRSolutionArraysViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  _db = [FIRFirestore firestore];
}

- (void)queryInCategory {
  // [START query_in_category]
  FIRQuery *query = [[self.db collectionWithPath:@"posts"]
      queryWhereField:@"categories.cats" isEqualTo:@YES];
  [query getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot,
                                      NSError * _Nullable error) {
    // ...
  }];
  // [END query_in_category]
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"

- (void)queryInCategoryTimestamp {
  // [START query_in_category_timestamp_invalid]
  FIRQuery *invalidQuery = [[[self.db collectionWithPath:@"posts"]
      queryWhereField:@"categories.cats" isEqualTo:@YES] queryOrderedByField:@"timestamp"];
  // [END query_in_category_timestamp_invalid]

  // [START query_in_category_timestamp]
  FIRQuery *query = [[[self.db collectionWithPath:@"posts"]
      queryWhereField:@"categories.cats" isGreaterThan:@0] queryOrderedByField:@"categories.cats"];
  // [END query_in_category_timestamp]
}

- (void)postWithArray {
  // [START post_with_array]
  NSDictionary *postWithArray = @{
    @"title": @"My great post",
    @"categories": @[@"technology", @"opinion", @"cats"]
  };
  // [END post_with_array]
}

- (void)postWithDictionary {
  // [START post_with_dict]
  NSDictionary *postWithDictionary = @{
    @"title": @"My great post",
    @"categories": @{
      @"technology": @YES,
      @"opinion": @YES,
      @"cats": @YES
    }
  };
  // [END post_with_dict]

}

- (void)postWithDictAdvanced {
  // [START post_with_dict_advanced]
  NSDictionary *postWithDictionary = @{
    @"title": @"My great post",
    @"categories": @{
      @"technology": @1502144665,
      @"opinion": @1502144665,
      @"cats": @1502144665
    }
  };
  // [END post_with_dict_advanced]
}

#pragma clang diagnostic pop

@end
