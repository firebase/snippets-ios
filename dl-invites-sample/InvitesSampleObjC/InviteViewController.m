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

#import "InviteViewController.h"
#import "InvitePresenter.h"

@implementation InviteTableViewDataSource {
  NSArray <id<InvitePresenter>> *_invitePresenters;
}

- (instancetype)initWithPresenters:(NSArray<id<InvitePresenter>> *)presenters {
  self = [super init];
  if (self != nil) {
    _invitePresenters = [presenters copy];
  }
  return self;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
  InviteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteTableViewCell" forIndexPath:indexPath];
  NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
    if (![evaluatedObject conformsToProtocol:@protocol(InvitePresenter)]) {
      return NO;
    }
    return [evaluatedObject isAvailable];
  }];
  NSArray *availablePresenters = [_invitePresenters filteredArrayUsingPredicate:filter];
  [cell populateWithPresenter:availablePresenters[indexPath.row]];
  return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger count = 0;
  for (id<InvitePresenter> presenter in _invitePresenters) {
    if (presenter.isAvailable) {
      count++;
    }
  }
  return count;
}

@end

@implementation InviteTableViewDelegate {
  NSArray <id<InvitePresenter>> *_invitePresenters;
}

- (instancetype)initWithPresenters:(NSArray<id<InvitePresenter>> *)presenters {
  self = [super init];
  if (self != nil) {
    _invitePresenters = [presenters copy];
  }
  return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger index = indexPath.row;
  for (id<InvitePresenter> presenter in _invitePresenters) {
    if (!presenter.isAvailable) { continue; }
    if (index == 0) {
      [presenter sendInvite];
    }
    index--;
  }
}

@end

@implementation InviteViewController {
  InviteTableViewDataSource *_dataSource;
  InviteTableViewDelegate *_delegate;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _dataSource = [[InviteTableViewDataSource alloc] initWithPresenters:DefaultInvitePresenters(self)];

  _delegate = [[InviteTableViewDelegate alloc] initWithPresenters:DefaultInvitePresenters(self)];

  self.tableView.dataSource = _dataSource;
  self.tableView.delegate = _delegate;
}

@end

@implementation InviteTableViewCell

- (void)populateWithPresenter:(id<InvitePresenter>)presenter {
  self.iconView.image = presenter.icon;
  self.nameLabel.text = presenter.name;
}

@end
