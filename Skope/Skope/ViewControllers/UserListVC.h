//
//  UserListVC.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/4/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "usersCell.h"
#import "ImportFiles.h"
#import "LocationTracker.h"
#import "AppDelegate.h"

@protocol UserListDelegate <NSObject>
- (void) userListActionBack;
- (void) userListActionGoProfile:(NSDictionary *)dicPf;
- (void) userListActionPassData:(NSDictionary *)dicPf;
@end


@interface UserListVC : UIViewController<UITableViewDataSource, UITableViewDelegate, LocationTrackerDelegate> {
    id dataFromHome;
    float regionMap;
    NSArray *arrData;
}
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property(nonatomic,assign)id<UserListDelegate> delegate;
@property (nonatomic, strong) id dataFromHome;
@property float regionMap;
@property (nonatomic) NSTimer* reloadUserListTimer;

- (IBAction)actionBackOfUser:(id)sender;

@end
