//
//  Copyright © 2019 Google. All rights reserved.
//

import Foundation
import FirebaseInAppMessaging

// [START fiam_card_action_delgate]
class CardActionFiamDelegate : NSObject, InAppMessagingDisplayDelegate {
    
    func messageClicked(_ inAppMessage: InAppMessagingDisplayMessage) {
        // ...
    }
    
    func messageDismissed(_ inAppMessage: InAppMessagingDisplayMessage,
                          dismissType: FIRInAppMessagingDismissType) {
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
