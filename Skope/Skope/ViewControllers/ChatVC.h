//
//  ChatVC.h
//  Skope
//
//  Created by CHAU HUYNH on 2/14/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHFComposeBarView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ImportFiles.h"
#import "ChatCellFromMe.h"
#import "ChatCellFromAnother.h"

@interface ChatVC : UIViewController<PHFComposeBarViewDelegate,UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource> {
    
}

@property (weak, nonatomic) IBOutlet UITableView *tblChat;
@property(nonatomic, strong) PHFComposeBarView *composeBarView;
@property(nonatomic, strong) UIView *container;

@property (strong, nonatomic) NSMutableArray *arrChatData;

- (IBAction)actionBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btBack;

@end
