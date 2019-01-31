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

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

NS_ASSUME_NONNULL_BEGIN

// [START invite_content]
/// The content within an invite, with optional fields to accommodate all presenters.
/// This type could be modified to also include an image, for sending invites over email.
@interface InviteContent : NSObject <NSCopying>

/// The subject of the message. Not used for invites without subjects, like text message invites.
@property (nonatomic, readonly, nullable) NSString *subject;

/// The body of the message. Indispensable content should go here.
@property (nonatomic, readonly, nullable) NSString *body;

/// The URL containing the invite. In link-copy cases, only this field will be used.
@property (nonatomic, readonly) NSURL *link;

- (instancetype)initWithSubject:(nullable NSString *)subject
                           body:(nullable NSString *)body
                           link:(NSURL *)link NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end
// [END invite_content]

// [START invite_presenter]
/// A type responsible for presenting an invite given using a specific method
/// given the content of the invite.
@protocol InvitePresenter <NSObject>

/// The name of the presenter. User-visible.
@property (nonatomic, readonly) NSString *name;

/// An icon representing the invite method. User-visible.
@property (nonatomic, readonly, nullable) UIImage *icon;

/// Whether or not the presenter's method is available. iOS devices that aren't phones
/// may not be able to send texts, for example.
@property (nonatomic, readonly) BOOL isAvailable;

/// The content of the invite. Some of the content type's fields may be unused.
@property (nonatomic, readonly) InviteContent *content;

/// Designated initializer.
- (instancetype)initWithContent:(InviteContent *)content presentingViewController:(UIViewController *)controller;

/// This method should cause the presenter to present the invite and then handle any actions
/// required to complete the invite flow.
- (void)sendInvite;

@end
// [END invite_presenter]

/// Returns a list of all presenters with default content configured.
NSArray <id<InvitePresenter>> *DefaultInvitePresenters(UIViewController *controller);

@interface EmailInvitePresenter: NSObject <InvitePresenter, MFMailComposeViewControllerDelegate>
- (instancetype)init NS_UNAVAILABLE;
@end

@interface SocialDeepLinkInvitePresenter: NSObject <InvitePresenter>
- (instancetype)init NS_UNAVAILABLE;
@end

@interface TextMessageInvitePresenter: NSObject <InvitePresenter, MFMessageComposeViewControllerDelegate>
- (instancetype)init NS_UNAVAILABLE;
@end

@interface CopyLinkInvitePresenter: NSObject <InvitePresenter>
- (instancetype)init NS_UNAVAILABLE;
@end

@interface OtherInvitePresenter: NSObject <InvitePresenter>
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
