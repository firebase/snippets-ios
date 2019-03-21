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

#import "FIRSolutionCountersViewController.h"

// [START counter_structs]
// counters/${ID}
@interface FIRCounter : NSObject
@property (nonatomic, readonly) NSInteger shardCount;
@end

@implementation FIRCounter
- (instancetype)initWithShardCount:(NSInteger)shardCount {
  self = [super init];
  if (self != nil) {
    _shardCount = shardCount;
  }
  return self;
}
@end

// counters/${ID}/shards/${NUM}
@interface FIRShard : NSObject
@property (nonatomic, readonly) NSInteger count;
@end

@implementation FIRShard
- (instancetype)initWithCount:(NSInteger)count {
  self = [super init];
  if (self != nil) {
    _count = count;
  }
  return self;
}
@end
// [END counter_structs]

@interface FIRSolutionCountersViewController ()
@property (nonatomic, readonly) FIRFirestore *db;
@end

@implementation FIRSolutionCountersViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  _db = [FIRFirestore firestore];
}

// [START create_counter]
- (void)createCounterAtReference:(FIRDocumentReference *)reference
                      shardCount:(NSInteger)shardCount {
  [reference setData:@{ @"numShards": @(shardCount) } completion:^(NSError * _Nullable error) {
    for (NSInteger i = 0; i < shardCount; i++) {
      NSString *shardName = [NSString stringWithFormat:@"%ld", (long)shardCount];
      [[[reference collectionWithPath:@"shards"] documentWithPath:shardName]
          setData:@{ @"count": @(0) }];
    }
  }];
}
// [END create_counter]

// [START increment_counter]
- (void)incrementCounterAtReference:(FIRDocumentReference *)reference
                         shardCount:(NSInteger)shardCount {
  // Select a shard of the counter at random
  NSInteger shardID = (NSInteger)arc4random_uniform((uint32_t)shardCount);
  NSString *shardName = [NSString stringWithFormat:@"%ld", (long)shardID];
  FIRDocumentReference *shardReference =
      [[reference collectionWithPath:@"shards"] documentWithPath:shardName];

  [shardReference updateData:@{
    @"count": [FIRFieldValue fieldValueForIntegerIncrement:1]
  }];
}
// [END increment_counter]

// [START get_count]
- (void)getCountWithReference:(FIRDocumentReference *)reference {
  [[reference collectionWithPath:@"shards"]
      getDocumentsWithCompletion:^(FIRQuerySnapshot *snapshot,
                                   NSError *error) {
        NSInteger totalCount = 0;
        if (error != nil) {
          // Error getting shards
          // ...
        } else {
          for (FIRDocumentSnapshot *document in snapshot.documents) {
            NSInteger count = [document[@"count"] integerValue];
            totalCount += count;
          }

          NSLog(@"Total count is %ld", (long)totalCount);
        }
  }];
}
// [END get_count]

@end
