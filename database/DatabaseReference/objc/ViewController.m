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

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)persistenceReference {
  // [START keep_synchronized]
  FIRDatabaseReference *scoresRef = [[FIRDatabase database] referenceWithPath:@"scores"];
  [scoresRef keepSynced:YES];
  // [END keep_synchronized]

  // [START stop_sync]
  [scoresRef keepSynced:NO];
  // [END stop_sync]
}

- (void)loadCached {
  // [START load_cached]
  FIRDatabaseReference *scoresRef = [[FIRDatabase database] referenceWithPath:@"scores"];
  [[[scoresRef queryOrderedByValue] queryLimitedToLast:4]
      observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"The %@ dinosaur's score is %@", snapshot.key, snapshot.value);
      }];
  // [END load_cached]

  // [START load_more_cached]
  [[[scoresRef queryOrderedByValue] queryLimitedToLast:2]
      observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"The %@ dinosaur's score is %@", snapshot.key, snapshot.value);
      }];
  // [END load_more_cached]

  // [START disconnected]
  FIRDatabaseReference *presenceRef = [[FIRDatabase database] referenceWithPath:@"disconnectmessage"];
  // Write a string when this client loses connection
  [presenceRef onDisconnectSetValue:@"I disconnected!"];
  // [END disconnected]

  // [START remove_disconnect]
  [presenceRef onDisconnectRemoveValueWithCompletionBlock:^(NSError *error, FIRDatabaseReference *reference) {
    if (error != nil) {
      NSLog(@"Could not establish onDisconnect event: %@", error);
    }
  }];
  // [END remove_disconnect]

  // [START cancel_disconnect]
  [presenceRef onDisconnectSetValue:@"I disconnected"];
  // some time later when we change our minds
  [presenceRef cancelDisconnectOperations];
  // [END cancel_disconnect]

  // [START test_connection]
  FIRDatabaseReference *connectedRef = [[FIRDatabase database] referenceWithPath:@".info/connected"];
  [connectedRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
    if([snapshot.value boolValue]) {
      NSLog(@"connected");
    } else {
      NSLog(@"not connected");
    }
  }];
  // [END test_connection]

  // [START last_online]
  FIRDatabaseReference *userLastOnlineRef = [[FIRDatabase database] referenceWithPath:@"users/morgan/lastOnline"];
  [userLastOnlineRef onDisconnectSetValue:[FIRServerValue timestamp]];
  // [END last_online]

  // [START clock_skew]
  FIRDatabaseReference *offsetRef = [[FIRDatabase database] referenceWithPath:@".info/serverTimeOffset"];
  [offsetRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
    NSTimeInterval offset = [(NSNumber *)snapshot.value doubleValue];
    NSTimeInterval estimatedServerTimeMs = [[NSDate date] timeIntervalSince1970] * 1000.0 + offset;
    NSLog(@"Estimated server time: %0.3f", estimatedServerTimeMs);
  }];
  // [END clock_skew]
}

- (void)combinedExample {
  // [START combined]
  // since I can connect from multiple devices, we store each connection instance separately
  // any time that connectionsRef's value is null (i.e. has no children) I am offline
  FIRDatabaseReference *myConnectionsRef = [[FIRDatabase database] referenceWithPath:@"users/morgan/connections"];

  // stores the timestamp of my last disconnect (the last time I was seen online)
  FIRDatabaseReference *lastOnlineRef = [[FIRDatabase database] referenceWithPath:@"users/morgan/lastOnline"];

  FIRDatabaseReference *connectedRef = [[FIRDatabase database] referenceWithPath:@".info/connected"];
  [connectedRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
    if([snapshot.value boolValue]) {
      // connection established (or I've reconnected after a loss of connection)

      // add this device to my connections list
      FIRDatabaseReference *con = [myConnectionsRef childByAutoId];

      // when this device disconnects, remove it
      [con onDisconnectRemoveValue];

      // The onDisconnect() call is before the call to set() itself. This is to avoid a race condition
      // where you set the user's presence to true and the client disconnects before the
      // onDisconnect() operation takes effect, leaving a ghost user.

      // this value could contain info about the device or a timestamp instead of just true
      [con setValue:@YES];


      // when I disconnect, update the last time I was seen online
      [lastOnlineRef onDisconnectSetValue:[FIRServerValue timestamp]];
    }
  }];
  // [END combined]
}

- (void)writeNewUser:(FIRUser *)user withName:(NSString *)username {
  // [START rtdb_write_new_user]
  [[[_ref child:@"users"] child:user.uid] setValue:@{@"username": username}];
  // [END rtdb_write_new_user]
}

- (void)writeNewUserWithCompletion:(FIRUser *)user withName:(NSString *)username {
  // [START rtdb_write_new_user_completion]
  [[[_ref child:@"users"] child:user.uid] setValue:@{@"username": username} withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
    if (error) {
      NSLog(@"Data could not be saved: %@", error);
    } else {
      NSLog(@"Data saved successfully.");
    }
  }];
  // [END rtdb_write_new_user_completion]
}

@end
