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

#import "CardActionFiamDelegate.h"

// [START fiam_card_action_delegate]
@implementation CardActionFiamDelegate

- (void)displayErrorForMessage:(nonnull FIRInAppMessagingDisplayMessage *)inAppMessage
                         error:(nonnull NSError *)error {
    // ...
}

- (void)impressionDetectedForMessage:(nonnull FIRInAppMessagingDisplayMessage *)inAppMessage {
    // ...
}

- (void)messageClicked:(nonnull FIRInAppMessagingDisplayMessage *)inAppMessage {
    // ...
}

- (void)messageDismissed:(nonnull FIRInAppMessagingDisplayMessage *)inAppMessage
             dismissType:(FIRInAppMessagingDismissType)dismissType {
    // ...
}

@end
// [END fiam_card_action_delegate]


// [START fiam_card_action_delegate_bundles]
@implementation CardActionFiamDelegate

- (void)messageClicked:(nonnull FIRInAppMessagingDisplayMessage *)inAppMessage {
	appData = inAppMessage.appData
	// ...
}

@end
// [END fiam_card_action_delegate_bundles]

