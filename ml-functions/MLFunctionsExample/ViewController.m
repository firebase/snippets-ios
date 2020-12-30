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

@import Firebase;

#import "ViewController.h"

@interface ViewController ()
// [START ml_functions_define]
@property(strong, nonatomic) FIRFunctions *functions;
// [END ml_functions_define]
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // [START ml_functions_init]
  self.functions = [FIRFunctions functions];
  // [END ml_functions_init]
}

- (void)prepareData {
  NSString *base64encoded = @"";
  NSDictionary *labelData = @{
    @"image": @{@"content": base64encoded},
    @"features": @{@"maxResults": @5, @"type": @"LABEL_DETECTION"}
  };
  NSDictionary *textData = @{
    @"image": @{@"content": base64encoded},
    @"features": @{@"type": @"TEXT_DETECTION"},
    @"imageContext": @{@"languageHints": @[@"en"]}
  };
  NSDictionary *textDataWithHints = @{
    @"image": @{@"content": base64encoded},
    @"features": @{@"type": @"TEXT_DETECTION"},
    @"imageContext": @{@"languageHints": @[@"en"]}
  };
  NSDictionary *documentTextData = @{
    @"image": @{@"content": base64encoded},
    @"features": @{@"type": @"DOCUMENT_TEXT_DETECTION"}
  };
  NSDictionary *landmarkData = @{
    @"image": @{@"content": base64encoded},
    @"features": @{@"maxResults": @5, @"type": @"LANDMARK_DETECTION"}
  };
}

- (void)annotateImage:(NSDictionary *)data {

  // [START function_annotateImage]
  [[_functions HTTPSCallableWithName:@"addMessage"]
                            callWithObject:data
                                completion:^(FIRHTTPSCallableResult * _Nullable result, NSError * _Nullable error) {
          if (error) {
            if (error.domain == FIRFunctionsErrorDomain) {
              FIRFunctionsErrorCode code = error.code;
              NSString *message = error.localizedDescription;
              NSObject *details = error.userInfo[FIRFunctionsErrorDetailsKey];
            }
            // ...
          }
          // Function completed succesfully
          // Get information about labeled objects
          
        }];
  // [END function_annotateImage]
}

- (void)getLabeledObjectsFromResult:(FIRHTTPSCallableResult *)result {
  NSArray *labelArray = result.data[@"labelAnnotations"];
  for (NSDictionary *labelObj in labelArray) {
    NSString *text = labelObj[@"description"];
    NSString *entityId = labelObj[@"mid"];
    NSNumber *confidence = labelObj[@"score"];
  }
}

- (void)getRecognizedTextsFromResult:(FIRHTTPSCallableResult *)result {
  NSDictionary *annotation = result.data[@"fullTextAnnotation"];
  if (annotation) {
    for (NSDictionary *page in annotation[@"pages"]) {
      NSMutableString *pageText = [NSMutableString new];
      for (NSDictionary *block in page[@"blocks"]) {
        NSMutableString *blockText = [NSMutableString new];
        for (NSDictionary *paragraph in block[@"paragraphs"]) {
          NSMutableString *paragraphText = [NSMutableString new];
          for (NSDictionary *word in paragraph[@"words"]) {
            NSMutableString *wordText = [NSMutableString new];
            for (NSDictionary *symbol in word[@"symbols"]) {
              NSString *text = symbol[@"text"];
              [wordText appendString:text];
              NSLog(@"Symbol text: %@ (confidence: %@\n", text, symbol[@"confidence"]);
            }
            NSLog(@"Word text: %@ (confidence: %@\n\n", wordText, word[@"confidence"]);
            NSLog(@"Word bounding box: %@\n", word[@"boundingBox"]);
            [paragraphText appendString:wordText];
          }
          NSLog(@"\nParagraph: \n%@\n", paragraphText);
          NSLog(@"Paragraph bounding box: %@\n", paragraph[@"boundingBox"]);
          NSLog(@"Paragraph Confidence: %@\n", paragraph[@"confidence"]);
          [blockText appendString:paragraphText];
        }
        [pageText appendString:blockText];
      }
    }
    NSLog(@"\nComplete annotation:");
    NSLog(@"\n%@", annotation[@"text"]);
  }
}

- (void)getRecognizedLandmarksFromResult:(FIRHTTPSCallableResult *)result {
  NSArray *labelArray = result.data[@"landmarkAnnotations"];
  for (NSDictionary *labelObj in labelArray) {
    NSString *landmarkName = labelObj[@"description"];
    NSString *entityId = labelObj[@"mid"];
    NSNumber *score = labelObj[@"score"];
    NSArray *bounds = labelObj[@"boundingPoly"];
    // Multiple locations are possible, e.g., the location of the depicted
    // landmark and the location the picture was taken.
    NSArray *locations = labelObj[@"locations"];
    for (NSDictionary *location in locations) {
      NSNumber *latitude = location[@"latLng"][@"latitude"];
      NSNumber *longitude = location[@"latLng"][@"longitude"];
    }
  }
}

@end
