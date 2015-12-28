//
//  PageContainVC.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/4/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserListVC.h"
#import "PostListVC.h"
#import "HomeVC.h"
#import "ProfileVC.h"
#import "MessageVC.h"

@interface PageContainVC : UIViewController<UIPageViewControllerDelegate, UserListDelegate, PostListDelegate, HomeListDelegate, ProfileDelegate, MessageDelegate>{
    NSArray *myViewControllers;
    ProfileVC *p1;
    UserListVC *p2;
    HomeVC *p3;
    PostListVC *p4;
}
@property (strong, nonatomic) UIPageViewController *pageViewController;

@end
