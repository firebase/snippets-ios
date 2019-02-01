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

#import <FirebaseDynamicLinks/FirebaseDynamicLinks.h>

@interface ViewController()

@property (nonatomic, readwrite) IBOutlet UILabel *linkLabel;

@property (nonatomic, readonly) UIActivityViewController *shareController;

@end

@implementation ViewController
@synthesize shareController=_shareController;

// [START share_controller]
- (UIActivityViewController *)shareController {
  if (_shareController == nil) {
    NSArray *activities = @[
      @"Learn how to share content via Firebase",
      [NSURL URLWithString:@"https://firebase.google.com"]
    ];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activities applicationActivities:nil];
    _shareController = controller;
  }
  return _shareController;
}

- (IBAction)shareLinkButtonPressed:(UIView *)sender {
  if (![sender isKindOfClass:[UIView class]]) {
    return;
  }
  
  self.shareController.popoverPresentationController.sourceView = sender;
  [self presentViewController:self.shareController animated:YES completion:nil];
}
// [END share_controller]

// [START generate_link]
- (NSURL *)generateContentLink {
  NSURL *baseURL = [NSURL URLWithString:@"https://your-custom-name.page.link"];
  NSString *domain = @"https://your-app.page.link";
  FIRDynamicLinkComponents *builder = [[FIRDynamicLinkComponents alloc] initWithLink:baseURL domainURIPrefix:domain];
  builder.iOSParameters = [FIRDynamicLinkIOSParameters parametersWithBundleID:@"com.your.bundleID"];
  builder.androidParameters = [FIRDynamicLinkAndroidParameters parametersWithPackageName:@"com.your.packageName"];

  // Fall back to the base url if we can't generate a dynamic link.
  return builder.link ?: baseURL;
}
// [END generate_link]

- (IBAction)shareButtonPressed:(id)sender {
  UIViewController *inviteController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"InviteViewController"];
  [self.navigationController pushViewController:inviteController animated:YES];
}

@end
