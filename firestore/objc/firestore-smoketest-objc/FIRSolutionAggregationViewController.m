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

#import "FIRSolutionAggregationViewController.h"

// [START restaurant_struct]
@interface FIRRestaurant : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) float averageRating;
@property (nonatomic, readonly) NSInteger ratingCount;

- (instancetype)initWithName:(NSString *)name
               averageRating:(float)averageRating
                 ratingCount:(NSInteger)ratingCount;

@end

@implementation FIRRestaurant

- (instancetype)initWithName:(NSString *)name
               averageRating:(float)averageRating
                 ratingCount:(NSInteger)ratingCount {
  self = [super init];
  if (self != nil) {
    _name = name;
    _averageRating = averageRating;
    _ratingCount = ratingCount;
  }
  return self;
}

@end
// [END restaurant_struct]

@interface FIRSolutionAggregationViewController ()
@property (nonatomic, readonly) FIRFirestore *db;
@end

@implementation FIRSolutionAggregationViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  _db = [FIRFirestore firestore];
}

- (void)getRatingsSubcollection {
  // [START get_ratings_subcollection]
  FIRQuery *query = [[[self.db collectionWithPath:@"restaurants"]
      documentWithPath:@"arinell-pizza"] collectionWithPath:@"ratings"];
  [query getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot,
                                      NSError * _Nullable error) {
    // ...
  }];
  // [END get_ratings_subcollection]
}

// [START add_rating_transaction]
- (void)addRatingTransactionWithRestaurantReference:(FIRDocumentReference *)restaurant
                                             rating:(float)rating {
  FIRDocumentReference *ratingReference =
      [[restaurant collectionWithPath:@"ratings"] documentWithAutoID];

  [self.db runTransactionWithBlock:^id (FIRTransaction *transaction,
                                        NSError **errorPointer) {
    FIRDocumentSnapshot *restaurantSnapshot =
        [transaction getDocument:restaurant error:errorPointer];

    if (restaurantSnapshot == nil) {
      return nil;
    }

    NSMutableDictionary *restaurantData = [restaurantSnapshot.data mutableCopy];
    if (restaurantData == nil) {
      return nil;
    }

    // Compute new number of ratings
    NSInteger ratingCount = [restaurantData[@"numRatings"] integerValue];
    NSInteger newRatingCount = ratingCount + 1;

    // Compute new average rating
    float averageRating = [restaurantData[@"avgRating"] floatValue];
    float newAverageRating = (averageRating * ratingCount + rating) / newRatingCount;

    // Set new restaurant info

    restaurantData[@"numRatings"] = @(newRatingCount);
    restaurantData[@"avgRating"] = @(newAverageRating);

    // Commit to Firestore
    [transaction setData:restaurantData forDocument:restaurant];
    [transaction setData:@{@"rating": @(rating)} forDocument:ratingReference];
    return nil;
  } completion:^(id  _Nullable result, NSError * _Nullable error) {
    // ...
  }];
}
// [END add_rating_transaction]

@end
