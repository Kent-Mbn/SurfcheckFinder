//
//  MessageListVC.h
//  Skope
//
//  Created by CHAU HUYNH on 2/13/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messageListCell.h"
#import "Common.h"

@interface MessageListVC : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tblMessList;
- (IBAction)actionBack:(id)sender;
- (void)loadMessages;

@end
