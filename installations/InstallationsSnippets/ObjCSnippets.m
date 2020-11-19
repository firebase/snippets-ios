//
//  Copyright (c) 2020 Google Inc.
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

@import FirebaseInstallations;

#import "ObjCSnippets.h"

@interface ObjCSnippets ()
@property(nonatomic, nullable) id<NSObject> installationIDObserver;
@end

@implementation ObjCSnippets

- (void)handleInstallationIDChange {
  // [START handle_installation_id_change]
  __weak __auto_type weakSelf = self;
  self.installationIDObserver = [[NSNotificationCenter defaultCenter]
          addObserverForName: FIRInstallationIDDidChangeNotification
                      object:nil
                       queue:nil
                  usingBlock:^(NSNotification * _Nonnull notification) {
      // Fetch new Installation ID
      [weakSelf fetchInstallationsID];
  }];
  // [END handle_installation_id_change]
}

- (void)fetchInstallationsID {
  // [START fetch_installation_id]
  [[FIRInstallations installations] installationIDWithCompletion:^(NSString *identifier, NSError *error) {
    if (error != nil) {
      NSLog(@"Error fetching Installation ID %@", error);
      return;
    }
    NSLog(@"Installation ID: %@", identifier);
  }];
  // [END fetch_installation_id]
}

- (void)fetchInstallationsToken {
  // [START fetch_installation_token]
  [[FIRInstallations installations] authTokenForcingRefresh:true
                                                 completion:^(FIRInstallationsAuthTokenResult *result, NSError *error) {
    if (error != nil) {
      NSLog(@"Error fetching Installation token %@", error);
      return;
    }
    NSLog(@"Installation auth token: %@", [result authToken]);
  }];
  // [END fetch_installation_token]
}

- (void)deleteInstallations {
  // [START delete_installation]
  [[FIRInstallations installations] deleteWithCompletion:^(NSError *error) {
     if (error != nil) {
       NSLog(@"Error deleting Installation %@", error);
       return;
     }
     NSLog(@"Installation deleted");
  }];
  // [END delete_installation]
}

@end
