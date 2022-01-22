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

#import <Foundation/Foundation.h>
@import Firebase;

// [START appcheck_custom_provider]
@interface YourCustomAppCheckProvider : NSObject <FIRAppCheckProvider>

@property FIRApp *app;

- (id)initWithApp:(FIRApp *)app;

@end

@implementation YourCustomAppCheckProvider

- (id)initWithApp:app {
    self = [super init];
    if (self) {
        self.app = app;
    }
    return self;
}

- (void)getTokenWithCompletion:(nonnull void (^)(FIRAppCheckToken * _Nullable,
                                                 NSError * _Nullable))handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Logic to exchange proof of authenticity for an App Check token.
        // [START_EXCLUDE]
        double expirationFromServer = 1234.0;
        NSString *tokenFromServer = @"token";
        // [END_EXCLUDE]

        // Create FIRAppCheckToken object.
        NSTimeInterval exp = expirationFromServer;
        FIRAppCheckToken *token
            = [[FIRAppCheckToken alloc] initWithToken:tokenFromServer
                                       expirationDate:[NSDate dateWithTimeIntervalSince1970:exp]];

        // Pass the token or error to the completion handler.
        handler(token, nil);
    });
}

@end
// [END appcheck_custom_provider]

// [START appcheck_custom_provider_factory]
@interface YourCustomAppCheckProviderFactory : NSObject <FIRAppCheckProviderFactory>
@end

@implementation YourCustomAppCheckProviderFactory

- (nullable id<FIRAppCheckProvider>)createProviderWithApp:(FIRApp *)app {
    return [[YourCustomAppCheckProvider alloc] initWithApp:app];
}

@end
// [END appcheck_custom_provider_factory]
