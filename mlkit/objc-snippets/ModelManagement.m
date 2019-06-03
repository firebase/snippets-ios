//
//  Copyright (c) 2019 Google Inc.
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

#import <Foundation/Foundation.h>
@import FirebaseMLCommon;

@interface ModelManagementSnippets : NSObject

- (void)setupRemoteModel;
- (void)setupModelDownloadNotifications;
- (void)setupLocalModel;

@end

@implementation ModelManagementSnippets

- (void)setupRemoteModel {
  // [START setup_remote_model]
  FIRModelDownloadConditions *initialConditions =
      [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:YES
                                           allowsBackgroundDownloading:YES];
  FIRModelDownloadConditions *updateConditions =
      [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:NO
                                           allowsBackgroundDownloading:YES];
  FIRRemoteModel *remoteModel = [[FIRRemoteModel alloc]
            initWithName:@"your_remote_model"  // The name you assigned in the console.
      allowsModelUpdates:YES
       initialConditions:initialConditions
        updateConditions:updateConditions];
  [[FIRModelManager modelManager] registerRemoteModel:remoteModel];
  // [END setup_remote_model]

  // [START start_download]
  NSProgress *downloadProgress = [[FIRModelManager modelManager] downloadRemoteModel:remoteModel];

  // ...

  if (downloadProgress.isFinished) {
    // The model is available on the device
  }
  // [END start_download]
}

- (void)setupModelDownloadNotifications {
  // [START setup_notifications]
  __weak typeof(self) weakSelf = self;

  [NSNotificationCenter.defaultCenter
      addObserverForName:FIRModelDownloadDidSucceedNotification
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *_Nonnull note) {
                if (weakSelf == nil | note.userInfo == nil) {
                  return;
                }
                __strong typeof(self) strongSelf = weakSelf;

                FIRRemoteModel *model = note.userInfo[FIRModelDownloadUserInfoKeyRemoteModel];
                if ([model.name isEqualToString:@"your_remote_model"]) {
                  // The model was downloaded and is available on the device
                }
              }];

  [NSNotificationCenter.defaultCenter
      addObserverForName:FIRModelDownloadDidFailNotification
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *_Nonnull note) {
                if (weakSelf == nil | note.userInfo == nil) {
                  return;
                }
                __strong typeof(self) strongSelf = weakSelf;

                NSError *error = note.userInfo[FIRModelDownloadUserInfoKeyError];
              }];
  // [END setup_notifications]
}

- (void)setupLocalModel {
  // [START setup_local_model]
  NSString *manifestPath = [NSBundle.mainBundle pathForResource:@"manifest"
                                                         ofType:@"json"
                                                    inDirectory:@"my_model"];
  FIRLocalModel *localModel = [[FIRLocalModel alloc]
      initWithName:@"your_local_model"  // Assign any name. You'll use it later to load the model.
              path:manifestPath];
  [[FIRModelManager modelManager] registerLocalModel:localModel];
  // [END setup_local_model]
}

@end
