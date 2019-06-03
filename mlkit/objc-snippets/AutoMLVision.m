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
@import Firebase;

@interface AutoMLVision : NSObject

- (void)labelImage:(FIRVisionImage *)image;

@end

@implementation AutoMLVision

- (void)labelImage:(FIRVisionImage *)image {
  // [START get_labeler]
  FIRVisionOnDeviceAutoMLImageLabelerOptions *labelerOptions =
      [[FIRVisionOnDeviceAutoMLImageLabelerOptions alloc]
          initWithRemoteModelName:@"my_remote_model"   // Or nil to not use a remote model
                   localModelName:@"my_local_model"];  // Or nil to not use a bundled model
  labelerOptions.confidenceThreshold = 0;  // Evaluate your model in the Firebase console
                                           // to determine an appropriate value.
  FIRVisionImageLabeler *labeler =
      [[FIRVision vision] onDeviceAutoMLImageLabelerWithOptions:labelerOptions];
  // [END get_labeler]

  // [START process_image]
  [labeler
      processImage:image
        completion:^(NSArray<FIRVisionImageLabel *> *_Nullable labels, NSError *_Nullable error) {
          if (error != nil || labels == nil) {
            return;
          }

          // Task succeeded.
          // [START_EXCLUDE]
          // [START get_labels]
          for (FIRVisionImageLabel *label in labels) {
            NSString *labelText = label.text;
            NSNumber *confidence = label.confidence;
          }
          // [END get_labels]
          // [END_EXCLUDE]
        }];
  // [END process_image]
}

@end
