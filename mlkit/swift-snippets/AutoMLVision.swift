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

import Firebase

class AutoMLVision {
    func label(image: VisionImage) {
        // [START get_labeler]
        let labelerOptions = VisionOnDeviceAutoMLImageLabelerOptions(
            remoteModelName: "your_remote_model",  // Or nil to not use a remote model
            localModelName: "your_local_model"     // Or nil to not use a bundled model
        )
        labelerOptions.confidenceThreshold = 0  // Evaluate your model in the Firebase console
                                                // to determine an appropriate value.
        let labeler = Vision.vision().onDeviceAutoMLImageLabeler(options: labelerOptions)
        // [END get_labeler]
        
        // [START process_image]
        labeler.process(image) { labels, error in
            guard error == nil, let labels = labels else { return }
            
            // Task succeeded.
            // [START_EXCLUDE]
            // [START get_labels]
            for label in labels {
                let labelText = label.text
                let confidence = label.confidence
            }
            // [END get_labels]
            // [END_EXCLUDE]
        }
        // [END process_image]
    }
}
