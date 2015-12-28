//
//  UserListVC.m
//  Skope
//
//  Created by Huynh Phong Chau on 3/4/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "UserListVC.h"
#import "PageContainVC.h"

@interface UserListVC ()

@end

@implementation UserListVC

@synthesize delegate;
@synthesize dataFromHome;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.locationTracker.delegate = self;
    //_tblView.backgroundColor = [UIColor clearColor];
    _tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void) viewDidAppear:(BOOL)animated {
    NSLog(@"region id: %f", self.regionMap);
    if (self.regionMap > 0) {
        [self callWSListUser];
    }
    
    //Reload after 5s
    self.reloadUserListTimer =
    [NSTimer scheduledTimerWithTimeInterval:5
                                     target:self
                                   selector:@selector(actionReloadUserList)
                                   userInfo:nil
                                    repeats:YES];
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

#pragma mark - TABLE DELEGATE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    usersCell *cell = [tableView dequeueReusableCellWithIdentifier:@"usersCellId" forIndexPath:indexPath];
    cell.lblName.text = arrData[indexPath.row][@"name"];
    NSLog(@"%f and %.0f", [arrData[indexPath.row][@"location"][@"distance"] floatValue], [arrData[indexPath.row][@"location"][@"distance"] floatValue]);
    cell.lblDistanceKm.text = [NSString stringWithFormat:@"%.0f km away", [arrData[indexPath.row][@"location"][@"distance"] floatValue]];
    [cell.imgAvatar sd_setImageWithURL:[NSURL URLWithString:arrData[indexPath.row][@"avatar"]] placeholderImage:nil];
    int divideN = 5;
    if ([Common checkIphoneVersion:@"6P"]) {
        divideN = 4;
    }
    CGRect frameCellArrow = cell.imgArrow.frame;
    frameCellArrow.origin.x = [Common widthScreen] - ([Common widthScreen] / divideN);
    frameCellArrow.origin.y = 45;
    cell.imgArrow.frame = frameCellArrow;
    
    [Common circleImageView:cell.imgAvatar];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self performSegueWithIdentifier:@"segueToProfile" sender:nil];
    if([delegate respondsToSelector:@selector(userListActionGoProfile:)])
    {
        if ([arrData count] > 0 && ([arrData count] > indexPath.row)) {
            [delegate userListActionGoProfile:arrData[indexPath.row]];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }

}

-(void)viewDidLayoutSubviews
{
    if ([_tblView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tblView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_tblView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tblView setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - FUNCTION
- (void) callWSListUser {
    if ([UserDefault user].strLat != 0 && [UserDefault user].strLong != 0 && [[UserDefault user].token length] > 0) {
        [Common showNetworkActivityIndicator];
        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
        NSMutableDictionary *request_param = [@{
                                                @"access_token":[UserDefault user].token,
                                                @"latitude":[UserDefault user].strLat,
                                                @"longitude":[UserDefault user].strLong,
                                                @"distance":@(self.regionMap),
                                                @"page":@(1),
                                                @"limit":@(100),
                                                } mutableCopy];
        //NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_LIST_USER));
        [manager GET:URL_SERVER_API(API_LIST_USER) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [Common hideNetworkActivityIndicator];
            [Common hideLoadingViewGlobal];
            //NSLog(@"json list user: %@", (NSDictionary *)responseObject);
            if ([Common validateRespone:responseObject]) {
                if (responseObject[@"data"][@"items"] != nil) {
                    arrData = responseObject[@"data"][@"items"];
                    //NSLog(@"data from: %@", responseObject[@"data"][@"items"]);
                    if ([arrData count] > 0) {
                        //                    if([delegate respondsToSelector:@selector(userListActionPassData:)])
                        //                    {
                        //                        [delegate userListActionPassData:arrData[0]];
                        //                    }
                    }
                    [_tblView reloadData];
                }
            } else {
                if ([Common validateAuthenFailed:responseObject]) {
                    [APP_DELEGATE setRootViewLogoutWithCompletion:^{
                        
                    }];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [Common hideLoadingViewGlobal];
        }];
    }
}

- (IBAction)actionBackOfUser:(id)sender {
    if([delegate respondsToSelector:@selector(userListActionBack)])
    {
        [delegate userListActionBack];
    }
}

- (void) actionReloadUserList {
    [self callWSListUser];
}

#pragma mark - LOCATION TRACKER DELEGATE
- (void) locationUpdated {
    //NSLog(@"update location...");
    [self callWSListUser];
}




@end
