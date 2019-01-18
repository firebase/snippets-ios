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

class InviteTableViewDataSource: NSObject, UITableViewDataSource {

  let invitePresenters: [InvitePresenter]

  @available(*, unavailable)
  public override init() {
    fatalError()
  }

  required public init(invitePresenters: [InvitePresenter]) {
    self.invitePresenters = invitePresenters
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return invitePresenters.filter { $0.isAvailable } .count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "InviteTableViewCell", for: indexPath)
        as! InviteTableViewCell
    cell.populate(with: invitePresenters.filter { $0.isAvailable} [indexPath.row])
    return cell
  }

}

class InviteTableViewDelegate: NSObject, UITableViewDelegate {

  let invitePresenters: [InvitePresenter]

  @available(*, unavailable)
  public override init() {
    fatalError()
  }

  required public init(invitePresenters: [InvitePresenter]) {
    self.invitePresenters = invitePresenters
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    invitePresenters.filter { $0.isAvailable } [indexPath.row].sendInvite()
  }

}

class InviteViewController: UIViewController {

  @IBOutlet var tableView: UITableView!

  private var dataSource: InviteTableViewDataSource! = nil
  private var delegate: InviteTableViewDelegate! = nil

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = InviteTableViewDataSource(invitePresenters:
        DefaultInvitePresenters(presentingController: self))
    delegate = InviteTableViewDelegate(invitePresenters:
        DefaultInvitePresenters(presentingController: self))

    tableView.delegate = delegate
    tableView.dataSource = dataSource
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tableView.reloadData()
  }

  deinit {
    tableView.dataSource = nil
    tableView.delegate = nil
  }

}

class InviteTableViewCell: UITableViewCell {

  @IBOutlet var iconView: UIImageView!
  @IBOutlet var nameLabel: UILabel!

  func populate(with presenter: InvitePresenter) {
    iconView.image = presenter.icon
    nameLabel.text = presenter.name
  }

}
