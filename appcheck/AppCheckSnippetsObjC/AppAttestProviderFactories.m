//
//  AppAttestProviderFactories.m
//  AppCheckSnippetsObjC
//
//  Created by Kevin Cheung on 7/26/21.
//

#import <Foundation/Foundation.h>
@import Firebase;

// [START appcheck_simple_appattest_factory]
@interface YourSimpleAppCheckProviderFactory : NSObject <FIRAppCheckProviderFactory>
@end

@implementation YourSimpleAppCheckProviderFactory

- (nullable id<FIRAppCheckProvider>)createProviderWithApp:(nonnull FIRApp *)app {
  return [[FIRAppAttestProvider alloc] initWithApp:app];
}

@end
// [END appcheck_simple_appattest_factory]

// [START appcheck_appattest_factory]
@interface YourAppCheckProviderFactory : NSObject <FIRAppCheckProviderFactory>
@end

@implementation YourAppCheckProviderFactory

- (nullable id<FIRAppCheckProvider>)createProviderWithApp:(nonnull FIRApp *)app {
  if (@available(iOS 14.0, *)) {
    return [[FIRAppAttestProvider alloc] initWithApp:app];
  } else {
    return [[FIRDeviceCheckProvider alloc] initWithApp:app];
  }
}

@end
// [START appcheck_appattest_factory]
