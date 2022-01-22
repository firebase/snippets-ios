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

import UIKit
import Firebase

class ViewController: UIViewController {
  // [START ml_functions_define]
  lazy var functions = Functions.functions()
  // [START ml_functions_define]

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  func prepareData(uiImage: UIImage) {
    // [START base64encodeImage]
    guard let imageData = uiImage.jpegData(compressionQuality: 1.0f) else { return }
    let base64encodedImage = imageData.base64EncodedString()
    // [END base64encodeImage]
  }

  func prepareLabelData(base64encodedImage: String) {
    // [START prepareLabelData]
    let requestData = [
      "image": ["content": base64encodedImage],
      "features": ["maxResults": 5, "type": "LABEL_DETECTION"]
    ]
    // [END prepareLabelData]
  }

  func prepareTextData(base64encodedImage: String) {
    let textDataWithHints = [
      "image": ["content": base64encodedImage],
      "features": ["type": "TEXT_DETECTION"],
      "imageContext": ["languageHints": ["en"]]
    ]
    let documentTextData = [
      "image": ["content": base64encodedImage],
      "features": ["type": "DOCUMENT_TEXT_DETECTION"]
    ]
    // [START prepareTextData]
    let requestData = [
      "image": ["content": base64encodedImage],
      "features": ["type": "TEXT_DETECTION"],
      "imageContext": ["languageHints": ["en"]]
    ]
    // [END prepareTextData]
  }

  func prepareLandmarkData(base64encodedImage: String) {
    // [START prepareLandmarkData]
    let requestData = [
      "image": ["content": base64encodedImage],
      "features": ["maxResults": 5, "type": "LANDMARK_DETECTION"]
    ]
    // [END prepareLandmarkData]
  }

  func annotateImage(requestData: Dictionary) {
    // [START function_annotateImage]
    functions.httpsCallable("annotateImage").call(requestData) { (result, error) in
      if let error = error as NSError? {
        if error.domain == FunctionsErrorDomain {
          let code = FunctionsErrorCode(rawValue: error.code)
          let message = error.localizedDescription
          let details = error.userInfo[FunctionsErrorDetailsKey]
        }
        // ...
      }
      // Function completed succesfully
    }
    // [END function_annotateImage]
  }

  func getLabeledObjectsFrom(_ result: HTTPSCallableResult?) {
    // [START getLabeledObjectsFrom]
    if let labelArray = (result?.data as? [String: Any])?["labelAnnotations"] as? [[String:Any]] {
      for labelObj in labelArray {
        let text = labelObj["description"]
        let entityId = labelObj["mid"]
        let confidence = labelObj["score"]
      }
    }
    // [END getLabeledObjectsFrom]
  }

  func getRecognizedTextsFrom(_ result: HTTPSCallableResult?) {
    // [START function_getRecognizedTexts]
    guard let annotation = (result?.data as? [String: Any])?["fullTextAnnotation"] as? [String: Any] else { return }
    print("%nComplete annotation:")
    let text = annotation["text"] as? String ?? ""
    print("%n\(text)")
    // [END function_getRecognizedTexts]
     
    // [START function_getRecognizedTexts_details]
    guard let pages = annotation["pages"] as? [[String: Any]] else { return }
    for page in pages {
    var pageText = ""
    guard let blocks = page["blocks"] as? [[String: Any]] else { continue }
    for block in blocks {
        var blockText = ""
        guard let paragraphs = block["paragraphs"] as? [[String: Any]] else { continue }
        for paragraph in paragraphs {
        var paragraphText = ""
        guard let words = paragraph["words"] as? [[String: Any]] else { continue }
        for word in words {
            var wordText = ""
            guard let symbols = word["symbols"] as? [[String: Any]] else { continue }
            for symbol in symbols {
            let text = symbol["text"] as? String ?? ""
            let confidence = symbol["confidence"] as? Float ?? 0.0
            wordText += text
            print("Symbol text: \(text) (confidence: \(confidence)%n")
            }
            let confidence = word["confidence"] as? Float ?? 0.0
            print("Word text: \(wordText) (confidence: \(confidence)%n%n")
            let boundingBox = word["boundingBox"] as? [Float] ?? [0.0, 0.0, 0.0, 0.0]
            print("Word bounding box: \(boundingBox.description)%n")
            paragraphText += wordText
        }
        print("%nParagraph: %n\(paragraphText)%n")
        let boundingBox = paragraph["boundingBox"] as? [Float] ?? [0.0, 0.0, 0.0, 0.0]
        print("Paragraph bounding box: \(boundingBox)%n")
        let confidence = paragraph["confidence"] as? Float ?? 0.0
        print("Paragraph Confidence: \(confidence)%n")
        blockText += paragraphText
        }
        pageText += blockText
    }
    // [END function_getRecognizedTexts_details]
  }

  func getRecognizedLandmarksFrom(_ result: HTTPSCallableResult?) {
    // [START getRecognizedLandmarksFrom]
    if let labelArray = (result?.data as? [String: Any])?["landmarkAnnotations"] as? [[String:Any]] {
      for labelObj in labelArray {
        let landmarkName = labelObj["description"]
        let entityId = labelObj["mid"]
        let score = labelObj["score"]
        let bounds = labelObj["boundingPoly"]
        // Multiple locations are possible, e.g., the location of the depicted
        // landmark and the location the picture was taken.
        guard let locations = labelObj["locations"] as? [[String: [String: Any]]] else { continue }
        for location in locations {
          let latitude = location["latLng"]?["latitude"]
          let longitude = location["latLng"]?["longitude"]
        }
      }
    }
    // [END getRecognizedLandmarksFrom]
  }
}
