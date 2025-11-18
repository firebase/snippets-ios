//
//  Copyright (c) 2025 Google LLC.
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

#import <FirebaseAnalytics/FirebaseAnalytics.h>
#import <FirebaseCore/FirebaseCore.h>

@import FirebaseRemoteConfig;
@import FirebaseCrashlytics;
@import FirebaseDatabase;
@import FirebaseMessaging;
@import FirebaseStorage;

@import UserNotifications;

// Redundant snippets: auth_view_import (unused)
// [START auth_import]
@import FirebaseAuth;
// [END auth_import]

// [START google_import]
@import GoogleSignIn;
// [END google_import]

@import FBSDKLoginKit;

@interface ObjcSnippets : NSObject

@end

@implementation ObjcSnippets

- (void)configureFirebase {
  // Redundant snippets:
  // - firebase_configure (AppDelegate_m_firebase_configure)
  // - configure_firebase
  // [START firebase_configure]
  [FIRApp configure];
  // [END firebase_configure]
}

- (void)setUserProperty {
  NSString *food = @"";
  // [START user_property]
  [FIRAnalytics setUserPropertyString:food forName:@"favorite_food"];
  // [END user_property]
}

- (void)logCustomEvent {
  NSString *name = @"";
  NSString *text = @"";
  // [START custom_event_objc]
  [FIRAnalytics logEventWithName:@"share_image"
                      parameters:@{
                                   @"name": name,
                                   @"full_text": text
                                   }];
  // [END custom_event_objc]
}

- (void)logPredefinedEvent {
  NSString *title = @"";
  // formerly custom_event_objc
  // [START log_event_objc]
  [FIRAnalytics logEventWithName:kFIREventSelectContent
                      parameters:@{
                                   kFIRParameterItemID: [NSString stringWithFormat:@"id-%@", title],
                                   kFIRParameterItemName: title,
                                   kFIRParameterContentType: @"image"
                                   }];
  // [END log_event_objc]
}

- (void)setCurrentScreen {
  // These strings must be <= 36 characters long in order for setScreenName:screenClass: to succeed.
  NSString *screenName = @"";
  NSString *screenClass = NSStringFromClass([self class]);

  // [START set_current_screen]
  [FIRAnalytics logEventWithName:kFIREventScreenView
                      parameters:@{kFIRParameterScreenClass: screenClass,
                                   kFIRParameterScreenName: screenName}];
  // [END set_current_screen]
}

- (void)getRemoteConfig {
  // [START get_remote_config_instance]
  FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
  // [END get_remote_config_instance]
}

- (void)enableDevMode {
  FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
  // [START enable_dev_mode]
  FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] init];
  remoteConfigSettings.minimumFetchInterval = 0;
  remoteConfig.configSettings = remoteConfigSettings;
  // [END enable_dev_mode]
}

- (void)setDefaultValues {
  FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
  // [START set_default_values]
  [remoteConfig setDefaultsFromPlistFileName:@"RemoteConfigDefaults"];
  // [END set_default_values]
}

- (void)addConfigUpdateListener {
  // [START add_config_update_listener]
  __weak FIRRemoteConfig *config = [FIRRemoteConfig remoteConfig];
  [config addOnConfigUpdateListener:^(FIRRemoteConfigUpdate * _Nonnull configUpdate, NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"Error listening for config updates %@", error.localizedDescription);
    } else {
      NSLog(@"Updated keys: %@", configUpdate.updatedKeys);
      [config activateWithCompletion:^(BOOL changed, NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Activate error %@", error.localizedDescription);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
          // update UI
        });
      }];
    }
  }];
  // [END add_config_update_listener]
}

- (void)fetchConfigWithFallback {
  FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
  // [START fetch_config_with_callback]
  [remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
    if (status == FIRRemoteConfigFetchStatusSuccess) {
      NSLog(@"Config fetched!");
      [remoteConfig activateWithCompletion:^(BOOL changed, NSError * _Nullable error) {
        if (error != nil) {
          NSLog(@"Activate error: %@", error.localizedDescription);
        } else {
          dispatch_async(dispatch_get_main_queue(), ^{
            // update UI
          });
        }
      }];
    } else {
      NSLog(@"Config not fetched");
      NSLog(@"Error %@", error.localizedDescription);
    }
  }];
  // [END fetch_config_with_callback]
}

- (void)getConfigValue {
  FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
  // [START get_config_value]
  NSString *welcomeMessage = remoteConfig[@"welcome_message"].stringValue;
  // [END get_config_value]
  NSLog(@"%@", welcomeMessage);
}

- (void)logAndCrash {
  // [START log_and_crash]
  [[FIRCrashlytics crashlytics] log:@"Cause Crash button clicked"];
  // crash
  int *x = NULL;
  *x = 10;
  // [END log_and_crash]
}

- (void)downloadImage {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = paths[0];
  NSString *filePath = [NSString stringWithFormat:@"file:%@/myimage.jpg", documentsDirectory];
  NSURL *fileURL = [NSURL URLWithString:filePath];

  FIRStorageReference *reference = [[FIRStorage storage] reference];
  // [START downloadimage]
  [[reference child:@"storagePath"]
        writeToFile:fileURL
         completion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
    if (error) {
      NSLog(@"Error downloading: %@", error);
      return;
    } else if (URL) {
      UIImage *image = [UIImage imageWithContentsOfFile:URL.path];
      NSLog(@"Download succeeded: %@", image);
    }
  }];
  // [END downloadimage]
}

- (void)storageReference {
  // [START configurestorage]
  FIRStorage *storage = [FIRStorage storage];
  // [END configurestorage]
}

- (void)storageAuth {
  // [START storageauth]
  // Using Cloud Storage for Firebase requires the user be authenticated. Here we are using
  // anonymous authentication.
  if (![FIRAuth auth].currentUser) {
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult,
                                                      NSError * _Nullable error) {
      if (error) {
        NSLog(@"%@", error.description);
      } else {
        // Sign in successful
      }
    }];
  }
  // [END storageauth]
}

- (void)uploadFile {
  // [START uploadimage]
  NSURL *imageFile = [[NSBundle mainBundle] URLForResource:@"image" withExtension:@"png"];
  FIRStorageReference *reference = [[FIRStorage storage] reference];
  [reference putFile:imageFile
            metadata:nil
          completion:^(FIRStorageMetadata *metadata, NSError *error) {
    if (error) {
      NSLog(@"Error uploading: %@", error);
      return;
    }
  }];
  // [END uploadimage]
}

@end

@interface MessagingAppDelegate: NSObject <UIApplicationDelegate, FIRMessagingDelegate, UNUserNotificationCenterDelegate>

@end

@implementation MessagingAppDelegate

- (void)setMessagingDelegate {
  // [START set_messaging_delegate]
  [FIRMessaging messaging].delegate = self;
  // [END set_messaging_delegate]
}

- (void)registerForNotifications {
  UIApplication *application = [UIApplication sharedApplication];
  // [START register_for_notifications]

  [UNUserNotificationCenter currentNotificationCenter].delegate = self;
  UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
      UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
  [[UNUserNotificationCenter currentNotificationCenter]
      requestAuthorizationWithOptions:authOptions
      completionHandler:^(BOOL granted, NSError * _Nullable error) {
        // ...
      }];

  [application registerForRemoteNotifications];
  // [END register_for_notifications]
}

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  // If you are receiving a notification message while your app is in the background,
  // this callback will not be fired until the user taps on the notification launching the application.
  // TODO: Handle data of notification

  // With swizzling disabled you must let Messaging know about the message, for Analytics
  // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

  // Print full message.
  NSLog(@"%@", userInfo);

  completionHandler(UIBackgroundFetchResultNewData);
}
// [END receive_message]

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10+ devices.
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
  NSDictionary *userInfo = notification.request.content.userInfo;

  // With swizzling disabled you must let Messaging know about the message, for Analytics
  // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

  // Print full message.
  NSLog(@"%@", userInfo);

  // Change this to your preferred presentation option
  completionHandler(UNNotificationPresentationOptionList |
                    UNNotificationPresentationOptionBanner |
                    UNNotificationPresentationOptionSound);
}

// [START refresh_token]
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}
// [END refresh_token]

- (void)logFCMToken {
  // [START log_fcm_reg_token]
  NSString *fcmToken = [FIRMessaging messaging].FCMToken;
  NSLog(@"Local FCM registration token: %@", fcmToken);
  // [END log_fcm_reg_token]

  NSString* displayToken = [NSString stringWithFormat:@"Logged FCM token: %@", fcmToken];

  // [START log_iid_reg_token]
  [[FIRMessaging messaging] tokenWithCompletion:^(NSString * _Nullable token, NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"Error fetching the remote FCM registration token: %@", error);
    } else {
      NSLog(@"Remote FCM registration token: %@", token);
      NSString* message =
        [NSString stringWithFormat:@"FCM registration token: %@", token];
      // display message
      NSLog(@"%@", message);
    }
  }];
  // [END log_iid_reg_token]
  NSLog(@"%@", displayToken);
}

- (void)subsribeToTopic {
  // [START subscribe_topic]
  [[FIRMessaging messaging] subscribeToTopic:@"weather"
                                  completion:^(NSError * _Nullable error) {
    NSLog(@"Subscribed to weather topic");
  }];
  // [END subscribe_topic]
}

@end
