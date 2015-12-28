//
//  MessageListVC.m
//  Skope
//
//  Created by CHAU HUYNH on 2/13/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "MessageListVC.h"
#import <Parse/Parse.h>

#import "Define.h"
#import "messages.h"
#import "utilities.h"

@interface MessageListVC ()
{
    NSMutableArray *messages;
}
@end

@implementation MessageListVC

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    
    _tblMessList.backgroundColor = [UIColor clearColor];
    _tblMessList.opaque = NO;
    _tblMessList.backgroundView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
    [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
    [query includeKey:PF_MESSAGES_LASTUSER];
    [query orderByDescending:PF_MESSAGES_UPDATEDACTION];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             [messages removeAllObjects];
             [messages addObjectsFromArray:objects];
             [self.tblMessList reloadData];
         }
         else NSLog(@"Network error.");
     }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [messages removeAllObjects];
    [self.tblMessList reloadData];
}


#pragma mark - TABLE DELEGATE
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    messageListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"mssCellId" forIndexPath:indexPath];
    [Common circleImageView:cell.imgViewAvatar];
    
    PFUser *lastUser = messages[indexPath.row][PF_MESSAGES_LASTUSER];
//    [imageUser setFile:lastUser[PF_USER_PICTURE]];
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:messages[indexPath.row][PF_MESSAGES_UPDATEDACTION]];

    
    cell.imgViewAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
    cell.lblName.text = messages[indexPath.row][PF_MESSAGES_DESCRIPTION];
    cell.lblFirstMss.text = messages[indexPath.row][PF_MESSAGES_LASTMESSAGE];
    cell.lblTimeMss.text = messages[indexPath.row][PF_MESSAGES_UPDATEDACTION];
    
    int xTimeDate = 200;
    int yTimeDate = 20;
    if ([Common checkIphoneVersion:@"6"]) {
        xTimeDate = 250;
        yTimeDate = 15;
    }
    if ([Common checkIphoneVersion:@"6P"]) {
        xTimeDate = 290;
        yTimeDate = 20;
    }
    CGRect frTimDate = cell.lblTimeMss.frame;
    frTimDate.origin.x = xTimeDate;
    frTimDate.origin.y = yTimeDate;
    cell.lblTimeMss.frame = frTimDate;
    
    CGRect frameCellArrow = cell.imgArrow.frame;
    frameCellArrow.origin.x = [Common widthScreen] - 40;
    frameCellArrow.origin.y = 70;
    cell.imgArrow.frame = frameCellArrow;
    
    return cell;
}

- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
