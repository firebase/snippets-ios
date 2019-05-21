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

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)suppressMessages {
    // [START fiam_suppress_messages]
    [FIRInAppMessaging inAppMessaging].messageDisplaySuppressed = YES;
    // [END fiam_suppress_messages]
}

-(void)enableDataCollection {
    // [START fiam_enable_data_collection]
    // Only needed if FirebaseInAppMessagingAutomaticDataCollectionEnabled is set to NO
    // in Info.plist
    [FIRInAppMessaging inAppMessaging].automaticDataCollectionEnabled = YES;
    // [END fiam_enable_data_collection]
}

@end
