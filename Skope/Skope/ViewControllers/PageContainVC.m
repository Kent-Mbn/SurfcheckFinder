//
//  PageContainVC.m
//  Skope
//
//  Created by Huynh Phong Chau on 3/4/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "PageContainVC.h"

@interface PageContainVC ()

@end

@implementation PageContainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    _pageViewController.edgesForExtendedLayout = UIRectEdgeNone;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    p1 = [self.storyboard instantiateViewControllerWithIdentifier:@"VIEW_PROFILE"];
    p1.delegate = self;
    
    p2 = [self.storyboard instantiateViewControllerWithIdentifier:@"VIEW_USER_LIST"];
    p2.delegate = self;
    
    p3 = [self.storyboard instantiateViewControllerWithIdentifier:@"VIEW_HOME"];
    p3.delegate = self;
    
    p4 = [self.storyboard instantiateViewControllerWithIdentifier:@"VIEW_POST_LIST"];
    p4.delegate = self;
    
    myViewControllers = @[p1,p2,p3,p4];
    
    [self.pageViewController setViewControllers:@[p3]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) disableScroll {
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = NO;
        }
    }
}

- (void) enableScroll {
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = YES;
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIPAGEVIEW CONTROLLER
-(UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return myViewControllers[index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController];
    
    if ((currentIndex == 0) || (currentIndex == NSNotFound)) {
        return nil;
    } else {
        --currentIndex;
        currentIndex = currentIndex % (myViewControllers.count);
        return [myViewControllers objectAtIndex:currentIndex];
    }
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController];
    if (currentIndex == NSNotFound) {
        return nil;
    }
    
    if (currentIndex == [myViewControllers count] - 1) {
        return nil;
    }
    
    ++currentIndex;
    currentIndex = currentIndex % (myViewControllers.count);
    return [myViewControllers objectAtIndex:currentIndex];
}

-(NSInteger)presentationIndexForPageViewController:
(UIPageViewController *)pageViewController
{
    return 1;
}

#pragma mark - USER_POST_HOME DELEGATE
- (void) messageActionBack {
    [self.pageViewController setViewControllers:@[p1]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES completion:nil];
}
- (void) userListActionBack {
    [self.pageViewController setViewControllers:@[p3]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES completion:nil];
}

- (void) postListActionBack {
    [self enableScroll];
    [self.pageViewController setViewControllers:@[p3]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES completion:nil];
}

- (void) profileActionBack {
    [self.pageViewController setViewControllers:@[p2]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES completion:nil];
}

- (void) homeListActionShowUser {
    [self.pageViewController setViewControllers:@[p2]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES completion:nil];
}

- (void) homeListActionShowPost {
    [self.pageViewController setViewControllers:@[p4]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES completion:nil];
}

- (void) userListActionGoProfile:(NSDictionary *)dicPf {
    [self.pageViewController setViewControllers:@[p1]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES completion:nil];
    p1.dicProfile = dicPf;
}

- (void) homeShowKeyBoard {
    [self disableScroll];
}

- (void) homeHideKeyBoard {
    [self enableScroll];
}

- (void) profileShowKeyBoard {
    [self disableScroll];
}

- (void) postListShowKeyboard {
    [self disableScroll];
}

- (void) profileHideKeyBoard {
    [self enableScroll];
}

- (void) postListHideKeyboard {
    [self enableScroll];
}

- (void) homeHideScreen:(float)data {
    p2.regionMap = data;
    p4.regionMap = data;
}

- (void) userListActionPassData:(NSDictionary *)dicPf {
    p1.dicProfile = dicPf;
}

- (void) showPostListScreen {
    [self disableScroll];
}

- (void) homePostDone:(BOOL)isReload {
    [self.pageViewController setViewControllers:@[p4]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES completion:nil];
    p4.isReload = isReload;
}



@end
