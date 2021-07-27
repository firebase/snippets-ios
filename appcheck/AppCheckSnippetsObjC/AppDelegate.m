//
//  Copyright (c) 2021 Google Inc.
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
@import Firebase;

@interface AppDelegate ()
@end

@interface YourAppCheckProviderFactory : NSObject <FIRAppCheckProviderFactory>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)initCustom {
    // [START appcheck_initialize_custom]
    YourAppCheckProviderFactory *providerFactory =
            [[YourAppCheckProviderFactory alloc] init];
    [FIRAppCheck setAppCheckProviderFactory:providerFactory];

    [FIRApp configure];
    // [END appcheck_initialize_custom]
}

- (void)initDebug {
    // [START appcheck_initialize_debug]
    FIRAppCheckDebugProviderFactory *providerFactory =
          [[FIRAppCheckDebugProviderFactory alloc] init];
    [FIRAppCheck setAppCheckProviderFactory:providerFactory];

    // Use Firebase library to configure APIs
    [FIRApp configure];
    // [END appcheck_initialize_debug]
}

- (void)nonFirebaseBackend {
    // [START appcheck_nonfirebase]
    [[FIRAppCheck appCheck] tokenForcingRefresh:NO
                                     completion:^(FIRAppCheckToken * _Nullable token,
                                                  NSError * _Nullable error) {
        if (error != nil) {
            // Handle any errors if the token was not retrieved.
            NSLog(@"Unable to retrieve App Check token: %@", error);
            return;
        }
        if (token == nil) {
            NSLog(@"Unable to retrieve App Check token.");
            return;
        }

        // Get the raw App Check token string.
        NSString *tokenString = token.token;

        // Include the App Check token with requests to your server.
        NSURL *url = [[NSURL alloc] initWithString:@"https://yourbackend.example.com/yourApiEndpoint"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"GET"];
        [request setValue:tokenString forHTTPHeaderField:@"X-Firebase-AppCheck"];

        NSURLSessionDataTask *task =
            [[NSURLSession sharedSession] dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
            // Handle response from your backend.
        }];
        [task resume];
    }];
    // [END appcheck_nonfirebase]
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
