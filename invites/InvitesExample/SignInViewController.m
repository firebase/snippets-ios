//
//  Copyright (c) Google Inc.
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

#import "SignInViewController.h"
#import "ViewController.h"
@import GoogleSignIn;
@import FirebaseCore;


@interface SignInViewController ()<GIDSignInDelegate, GIDSignInUIDelegate>
@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
@property(weak, nonatomic) IBOutlet UILabel *bgText;
@end

@implementation SignInViewController

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  _bgText.text = @"Invites\niOS demo";

  [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;

  // Sign the user in automatically
  [GIDSignIn sharedInstance].uiDelegate = self;
  [[GIDSignIn sharedInstance] signInSilently];

  // TODO(developer): Configure the sign-in button look/feel
  [GIDSignIn sharedInstance].delegate = self;
}

- (void)signIn:(GIDSignIn *)signIn
    didSignInForUser:(GIDGoogleUser *)user
           withError:(NSError *)error {
  if (error == nil) {
    // User Successfully signed in.
    // TODO: Remove async after, when GIDSignIn is started getting called after dissmissVC
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self performSegueWithIdentifier:@"SignedInScreen" sender:self];
    });
  } else {
    // Something went wrong; for example, the user could haved clicked cancel.
    NSLog(@"%@", error.localizedDescription);
  }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (IBAction)unwindToSignIn:(UIStoryboardSegue *)sender {
  [GIDSignIn sharedInstance].delegate = self;
}
@end
