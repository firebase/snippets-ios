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

import FirebaseInAppMessaging

// [START fiam_card_action_delegate]
class CardActionFiamDelegate : NSObject, InAppMessagingDisplayDelegate {
    
    func messageClicked(_ inAppMessage: InAppMessagingDisplayMessage) {
        // ...
    }
    
    func messageDismissed(_ inAppMessage: InAppMessagingDisplayMessage,
                          dismissType: InAppMessagingDismissType) {
        // ...
    }
    
    func impressionDetected(for inAppMessage: InAppMessagingDisplayMessage) {
        // ...
    }
    
    func displayError(for inAppMessage: InAppMessagingDisplayMessage, error: Error) {
        // ...
    }

}
// [END fiam_card_action_delegate]


// [START fiam_card_action_delegate_bundles]
class CardActionDelegate : NSObject, InAppMessagingDisplayDelegate {
    
    func messageClicked(_ inAppMessage: InAppMessagingDisplayMessage) {
	// Get data bundle from the inapp message
	let appData = inAppMessage.appData
	// ...
    }
}
// [END fiam_card_action_delegate_bundles]
