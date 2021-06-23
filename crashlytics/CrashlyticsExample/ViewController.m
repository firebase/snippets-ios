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

@end

// [START forceCrash]
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.

    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20, 50, 100, 30);
    [button setTitle:@"Crash" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(crashButtonTapped:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (IBAction)crashButtonTapped:(id)sender {
    @[][1];
}
// [END forceCrash]

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

- (void)setCustomKey {
  // [START setCustomKey]
  // Set int_key to 100.
  [[FIRCrashlytics crashlytics] setCustomValue:@(100) forKey:@"int_key"];

  // Set str_key to "hello".
  [[FIRCrashlytics crashlytics] setCustomValue:@"hello" forKey:@"str_key"];
  // [END setCustomKey]
}

- (void)setCustomValue {
  // [START setCustomValue]
  [[FIRCrashlytics crashlytics] setCustomValue:@(100) forKey:@"int_key"];

  // Set int_key to 50 from 100.
  [[FIRCrashlytics crashlytics] setCustomValue:@(50) forKey:@"int_key"];
  // [END setCustomValue]
}

- (void)setCustomKeys {
  // [START setCustomKeys]
  NSDictionary *keysAndValues =
      @{@"string key" : @"string value",
        @"string key 2" : @"string value 2",
        @"boolean key" : @(YES),
        @"boolean key 2" : @(NO),
        @"float key" : @(1.01),
        @"float key 2" : @(2.02)};

  [[FIRCrashlytics crashlytics] setCustomKeysAndValues: keysAndValues];
  // [END setCustomKeys]
}

- (void)enableOptIn {
  // [START enableOptIn]
  [[FIRCrashlytics crashlytics] setCrashlyticsCollectionEnabled:YES];
  // [END enableOptIn]
}

- (void)logExceptions {
  // [START createError]
  NSDictionary *userInfo = @{
    NSLocalizedDescriptionKey: NSLocalizedString(@"The request failed.", nil),
    NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The response returned a 404.", nil),
    NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Does this page exist?", nil),
    @"ProductID": @"123456",
    @"View": @"MainView",
  };

  NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                       code:-1001
                                   userInfo:userInfo];
  // [END createError]

  // [START recordError]
  [[FIRCrashlytics crashlytics] recordError:error];
  // [END recordError]
}

- (void)setUserId {
  // [START setUserId]
  [[FIRCrashlytics crashlytics] setUserID:@"123456789"];
  // [END setUserId]
}

@end
