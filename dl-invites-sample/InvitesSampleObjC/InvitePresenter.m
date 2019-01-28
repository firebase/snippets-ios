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

#import "InvitePresenter.h"

@implementation InviteContent

- (instancetype)init {
  abort();
}

- (instancetype)initWithSubject:(NSString *)subject
                           body:(NSString *)body
                           link:(NSURL *)link {
  self = [super init];
  if (self != nil) {
    _subject = subject;
    _body = body;
    _link = link;
  }
  return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
  return self;
}

@end

NSArray <id<InvitePresenter>> *DefaultInvitePresenters(UIViewController *controller) {
  NSURL *url = [[NSURL alloc] initWithString:@"https://github.com/firebase"];
  return @[
    [[EmailInvitePresenter alloc] initWithContent:[[InviteContent alloc]
        initWithSubject:@"Check out Firebase's great samples!"
        body:@"This holiday season, get a free sample included when you clone any Firebase sample on GitHub."
        link:url] presentingViewController:controller],
    [[SocialDeepLinkInvitePresenter alloc] initWithContent:[[InviteContent alloc]
        initWithSubject:nil body:@"Come join me on Firebase, Google's developer platform! "
        link:url] presentingViewController:controller],
    [[TextMessageInvitePresenter alloc] initWithContent:[[InviteContent alloc]
        initWithSubject:nil body:@"Check out Firebase's great samples on GitHub! "
        link:url] presentingViewController:controller],
    [[CopyLinkInvitePresenter alloc] initWithContent:[[InviteContent alloc]
        initWithSubject:nil body:nil link:url] presentingViewController:controller],
    [[OtherInvitePresenter alloc] initWithContent:[[InviteContent alloc]
        initWithSubject:nil body:@"Check out Firebase's great samples on GitHub! "
        link:url] presentingViewController:controller]
  ];
}

@implementation EmailInvitePresenter {
  __weak UIViewController *_Nullable _presentingController;
  MFMailComposeViewController *_Nullable _mailController;
}
@synthesize content=_content;

- (NSString *)name {
  return @"Email";
}

- (UIImage *)icon {
  return [UIImage imageNamed:@"email"];
}

- (BOOL)isAvailable {
  return [MFMailComposeViewController canSendMail];
}

- (instancetype)initWithContent:(InviteContent *)content presentingViewController:(UIViewController *)controller {
  self = [super init];
  if (self != nil) {
    _content = content;
    _presentingController = controller;
  }
  return self;
}

- (void)sendInvite {
  MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
  mailController.mailComposeDelegate = self;
  [mailController setSubject:self.content.subject];
  NSString *body = [self.content.body stringByAppendingFormat:@"\n%@", self.content.link];
  [mailController setMessageBody:body isHTML:NO];
  _mailController = mailController;
  [_presentingController presentViewController:mailController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
  if (error != nil) {
    NSLog(@"Error sending mail invite: %@", error);
  }
  [_mailController dismissViewControllerAnimated:YES completion:nil];
  _mailController.mailComposeDelegate = nil;
  _mailController = nil;
}

@end

@implementation SocialDeepLinkInvitePresenter {
  BOOL _checkedForAvailability;
}
@synthesize content=_content;
@synthesize isAvailable=_isAvailable;

// This url is provided for the sake of example, this isn't actually a viable
// url for deep linking into Twitter.
- (NSURL *)socialBaseURL {
  return [NSURL URLWithString:@"twitter://compose"];
}

- (NSString *)name {
  return @"Social";
}

- (UIImage *)icon {
  return [UIImage imageNamed:@"social"];
}

- (BOOL)isAvailable {
  if (!_checkedForAvailability) {
    _isAvailable = [[UIApplication sharedApplication] canOpenURL:[self socialBaseURL]];
    _checkedForAvailability = YES;
  }

  return _isAvailable;
}

- (instancetype)initWithContent:(InviteContent *)content presentingViewController:(UIViewController *)controller {
  self = [super init];
  if (self != nil) {
    _content = content;
    _checkedForAvailability = NO;
    _isAvailable = NO;
  }
  return self;
}

- (void)sendInvite {
  NSString *body = self.content.body ?: @"";
  NSArray *queryItems = @[
      [NSURLQueryItem queryItemWithName:@"body" value:[body stringByAppendingString:self.content.link.absoluteString]]
  ];

  NSURLComponents *components = [NSURLComponents componentsWithURL:[self socialBaseURL]
                                           resolvingAgainstBaseURL:YES];
  components.queryItems = queryItems;

  if (components.URL == nil) {
    NSLog(@"Unable to build deep link URL with content %@", self.content);
  } else {
    [[UIApplication sharedApplication] openURL:components.URL
                                       options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @(YES)}
                             completionHandler:nil];
  }
}

@end

@implementation TextMessageInvitePresenter {
  MFMessageComposeViewController *_Nullable _messageController;
  __weak UIViewController *_Nullable _presentingController;
}
@synthesize content=_content;

- (NSString *)name {
  return @"Message";
}

- (UIImage *)icon {
  return [UIImage imageNamed:@"sms"];
}

- (BOOL)isAvailable {
  return [MFMessageComposeViewController canSendText];
}

- (instancetype)initWithContent:(InviteContent *)content presentingViewController:(UIViewController *)controller {
  self = [super init];
  if (self != nil) {
    _content = content;
    _presentingController = controller;
  }
  return self;
}

- (void)sendInvite {
  MFMessageComposeViewController *messageUI = [[MFMessageComposeViewController alloc] init];
  messageUI.messageComposeDelegate = self;
  NSString *contentBody = self.content.body ?: @"";
  NSString *bodyText = [contentBody stringByAppendingString:self.content.link.absoluteString];
  messageUI.body = bodyText;
  _messageController = messageUI;
  [_presentingController presentViewController:messageUI animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
  [_messageController dismissViewControllerAnimated:YES completion:nil];
  _messageController.messageComposeDelegate = nil;
  _messageController = nil;
}

@end

@implementation CopyLinkInvitePresenter
@synthesize content=_content;

- (NSString *)name {
  return @"Copy Link";
}

- (UIImage *)icon {
  return [UIImage imageNamed:@"copy"];
}

- (BOOL)isAvailable {
  return YES;
}

- (instancetype)initWithContent:(InviteContent *)content presentingViewController:(UIViewController *)controller {
  self = [super init];
  if (self != nil) {
    _content = content;
  }
  return self;
}

- (void)sendInvite {
  [UIPasteboard generalPasteboard].string = self.content.link.absoluteString;
  // Display a "Link copied!" dialogue/banner here.
  NSLog(@"Link copied!");
}

@end

@implementation OtherInvitePresenter {
  __weak UIViewController *_Nullable _presentingController;
  UIActivityViewController *_Nonnull _activityViewController;
}
@synthesize content=_content;

- (NSString *)name {
  return @"More";
}

- (UIImage *)icon {
  return [UIImage imageNamed:@"more"];
}

- (BOOL)isAvailable {
  return YES;
}

- (instancetype)initWithContent:(InviteContent *)content presentingViewController:(UIViewController *)controller {
  self = [super init];
  if (self != nil) {
    _content = content;
    _presentingController = controller;
  }
  return self;
}

- (UIActivityViewController *)activityViewController {
  if (_activityViewController == nil) {
    NSMutableArray *activities = [NSMutableArray array];
    if (self.content.subject) {
      [activities addObject:self.content.subject];
    }
    if (self.content.body) {
      [activities addObject:self.content.body];
    }

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activities
                                                                             applicationActivities:nil];
    _activityViewController = controller;
  }
  return _activityViewController;
}

- (void)sendInvite {
  [_presentingController presentViewController:[self activityViewController] animated:YES completion:nil];
}

@end
