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
@property(strong, nonatomic) FIRCrashlytics *crashlytics;
// [END ml_functions_define]
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // [START crashlytics_init]
  self.crashlytics = [FIRCrashlytics crashlytics];
  // [END crashlytics_init]
}

- (void)customizeStackTraces {
  // [START customizeStackTraces]
  FIRExceptionModel *model =
      [FIRExceptionModel exceptionModelWithName:@"FooException" reason:@"There was a foo."];
  model.stackTrace = @[
    [FIRStackFrame stackFrameWithSymbol:@"makeError" file:@"handler.js" line:495],
    [FIRStackFrame stackFrameWithSymbol:@"then" file:@"routes.js" line:102],
    [FIRStackFrame stackFrameWithSymbol:@"main" file:@"app.js" line:12],
  ];

  [[FIRCrashlytics crashlytics] recordExceptionModel:model];
  // [END customizeStackTraces]
}

- (void)customizeStackTracesAddress {
  // [START customizeStackTracesAddress]
  FIRExceptionModel *model =
      [FIRExceptionModel exceptionModelWithName:@"FooException" reason:@"There was a foo."];
  model.stackTrace = @[
    [FIRStackFrame stackFrameWithAddress:0xfa12123],
    [FIRStackFrame stackFrameWithAddress:12412412],
    [FIRStackFrame stackFrameWithAddress:194129124],
  ];


  [[FIRCrashlytics crashlytics] recordExceptionModel:model];
  // [END customizeStackTracesAddress]
}

@end
