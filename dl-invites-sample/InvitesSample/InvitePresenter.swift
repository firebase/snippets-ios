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

import UIKit
import MessageUI

// [START invite_content]
/// The content within an invite, with optional fields to accommodate all presenters.
/// This type could be modified to also include an image, for sending invites over email.
struct InviteContent {

  /// The subject of the message. Not used for invites without subjects, like text message invites.
  var subject: String?

  /// The body of the message. Indispensable content should go here.
  var body: String?

  /// The URL containing the invite. In link-copy cases, only this field will be used.
  var link: URL

}
// [END invite_content]

// [START invite_presenter]
/// A type responsible for presenting an invite given using a specific method
/// given the content of the invite.
protocol InvitePresenter {

  /// The name of the presenter. User-visible.
  var name: String { get }

  /// An icon representing the invite method. User-visible.
  var icon: UIImage? { get }

  /// Whether or not the presenter's method is available. iOS devices that aren't phones
  /// may not be able to send texts, for example.
  var isAvailable: Bool { get }

  /// The content of the invite. Some of the content type's fields may be unused.
  var content: InviteContent { get }

  /// Designated initializer.
  init(content: InviteContent, presentingController: UIViewController)

  /// This method should cause the presenter to present the invite and then handle any actions
  /// required to complete the invite flow.
  func sendInvite()

}
// [END invite_presenter]

/// Returns a list of all presenters with default content configured.
func DefaultInvitePresenters(presentingController: UIViewController) -> [InvitePresenter] {
  let url = URL(string: "https://github.com/firebase")!
  return [
    EmailInvitePresenter(
      content: InviteContent(
        subject: "Check out Firebase's great samples!",
        body: "This holiday season, get a free sample included when you clone any Firebase sample on GitHub. ",
        link: url
      )
      , presentingController: presentingController
    ),
    SocialDeepLinkInvitePresenter(
      content: InviteContent(
        subject: nil,
        body: "Come join me on Firebase, Google's developer platform! ",
        link: url
      ),
      presentingController: presentingController
    ),
    TextMessageInvitePresenter(
      content: InviteContent(
        subject: nil,
        body: "Check out Firebase's great samples on GitHub! ",
        link: url
      ),
      presentingController: presentingController
    ),
    CopyLinkInvitePresenter(
      content: InviteContent(
        subject: nil,
        body: nil,
        link: url
      ), presentingController: presentingController
    ),
    OtherInvitePresenter(
      content: InviteContent(
        subject: nil,
        body: "Check out Firebase's great samples on GitHub! ",
        link: url
      ),
      presentingController: presentingController
    )
  ]
}

final class EmailInvitePresenter: NSObject, InvitePresenter, MFMailComposeViewControllerDelegate {

  let name = "Email"

  var icon: UIImage? {
    return UIImage(named: "email")
  }

  let content: InviteContent

  private let presentingController: UIViewController

  var isAvailable: Bool {
    return MFMailComposeViewController.canSendMail()
  }

  private weak var mailController: MFMailComposeViewController? = nil

  required init(content: InviteContent, presentingController: UIViewController) {
    self.content = content
    self.presentingController = presentingController
  }

  func sendInvite() {
    let mailUI = MFMailComposeViewController()
    mailUI.mailComposeDelegate = self

    mailUI.setSubject(content.subject ?? "")
    mailUI.setMessageBody((content.body ?? "") + content.link.absoluteString, isHTML: false)

    mailController = mailUI

    presentingController.present(mailUI, animated: true, completion: nil)
  }

  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult,
                             error: Error?) {
    if let error = error {
      print("Error sending mail invite: \(error)")
    }
    mailController?.dismiss(animated: true, completion: nil)
    mailController?.mailComposeDelegate = nil
    mailController = nil
  }

}

final class SocialDeepLinkInvitePresenter: InvitePresenter {

  let name = "Social"

  var icon: UIImage? {
    return UIImage(named: "social")
  }

  // This url is provided for the sake of example, this isn't actually a viable
  // url for deep linking into Twitter.
  private var socialBaseURL = URL(string: "twitter://compose")!

  lazy private(set) var isAvailable: Bool = {
    return UIApplication.shared.canOpenURL(socialBaseURL)
  }()

  var content: InviteContent

  required init(content: InviteContent, presentingController: UIViewController) {
    self.content = content
  }

  func sendInvite() {
    let queryItems = [
      URLQueryItem(name: "body", value: (content.body ?? "") + content.link.absoluteString)
    ]
    var components = URLComponents(url: socialBaseURL, resolvingAgainstBaseURL: true)
    components?.queryItems = queryItems

    if let url = components?.url {
      UIApplication.shared.open(url, options: [.universalLinksOnly: true], completionHandler: nil)
    } else {
      fatalError("Unable to build deep link url with content \(content)")
    }
  }

}

final class TextMessageInvitePresenter: NSObject, InvitePresenter, MFMessageComposeViewControllerDelegate {

  let name = "Message"

  var icon: UIImage? {
    return UIImage(named: "sms")
  }

  let content: InviteContent

  private let presentingController: UIViewController

  var isAvailable: Bool {
    return MFMessageComposeViewController.canSendText()
  }

  private weak var messageController: MFMessageComposeViewController? = nil

  required init(content: InviteContent, presentingController: UIViewController) {
    self.content = content
    self.presentingController = presentingController
  }

  func sendInvite() {
    let messageUI = MFMessageComposeViewController()
    messageUI.messageComposeDelegate = self

    // Sending texts discards the content's subject line, if there is one.
    messageUI.body = (content.body ?? "") + content.link.absoluteString

    messageController = messageUI

    presentingController.present(messageUI, animated: true, completion: nil)
  }

  func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                    didFinishWith result: MessageComposeResult) {
    messageController?.dismiss(animated: true, completion: nil)
    messageController?.messageComposeDelegate = nil
    messageController = nil
  }

}

final class CopyLinkInvitePresenter: InvitePresenter {

  let name = "Copy Link"

  var icon: UIImage? {
    return UIImage(named: "copy")
  }

  var isAvailable: Bool {
    return true
  }

  var content: InviteContent

  required init(content: InviteContent, presentingController: UIViewController) {
    self.content = content
  }

  func sendInvite() {
    UIPasteboard.general.string = content.link.absoluteString
    // Display a "Link copied!" dialogue here.
    print("Link copied!")
  }

}

final class OtherInvitePresenter: InvitePresenter {

  let name = "More"

  var icon: UIImage? {
    return UIImage(named: "more")
  }

  var isAvailable: Bool {
    return true
  }

  var content: InviteContent

  private let presentingController: UIViewController

  init(content: InviteContent, presentingController: UIViewController) {
    self.content = content
    self.presentingController = presentingController
  }

  lazy private var activityController: UIActivityViewController = {
    var activities: [Any] = []
    [content.subject, content.body].forEach {
      if let value = $0 {
        activities.append(value)
      }
    }
    activities.append(content.link)

    let controller = UIActivityViewController(activityItems: activities,
                                              applicationActivities: nil)
    return controller
  }()

  func sendInvite() {
    presentingController.present(activityController, animated: true, completion: nil)
  }

}
