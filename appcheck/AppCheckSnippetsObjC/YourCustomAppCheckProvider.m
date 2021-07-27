//
//  YourCustomAppCheckProvider.m
//  AppCheckSnippetsObjC
//
//  Created by Kevin Cheung on 7/26/21.
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
        NSTimeInterval exp = expirationFromServer - 60;  // Refresh the token early to handle clock skew.
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
