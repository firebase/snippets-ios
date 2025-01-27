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

#import "AppDelegate.h"

@import FirebaseCore;
@import FirebaseInAppMessaging;

#import "CardActionFiamDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    
    // [START fiam_register_delegate]
    CardActionFiamDelegate *myFiamDelegate = [CardActionFiamDelegate new];
    [FIRInAppMessaging inAppMessaging].delegate = myFiamDelegate;
    // [END fiam_register_delegate]
    return YES;
}

@end
