//
//  MessageVC.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHFComposeBarView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ImportFiles.h"
#import "ChatCellFromMe.h"
#import "ChatCellFromAnother.h"
#import "JSQMessages.h"

@protocol MessageDelegate <NSObject>
- (void) messageActionBack;
@end

@interface MessageVC : UIViewController<PHFComposeBarViewDelegate,UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tblMessage;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property(nonatomic, strong) PHFComposeBarView *composeBarView;
@property(nonatomic, strong) UIView *container;
@property(nonatomic, strong) NSString *groupId;
@property(nonatomic, strong) NSString *emailUser;

@property (strong, nonatomic) NSMutableArray *arrMssData;
@property(nonatomic,assign)id<MessageDelegate> delegate;
@property (copy, nonatomic) NSString *senderId;
@property (copy, nonatomic) NSString *senderDisplayName;

- (IBAction)actionBack:(id)sender;

@end
