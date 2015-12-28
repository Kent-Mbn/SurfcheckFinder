//
//  MyProfileVC.m
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "MyProfileVC.h"

CGRect const kInitialViewFrameMPFInput = { 0.0f, 0.0f, 320.0f, 480.0f };
#define COUNT_START_MPF_COMMENTS 2

@interface MyProfileVC ()

@end


@implementation MyProfileVC
@synthesize arrDummyComments = _arrDummyComments;
@synthesize dicProfile;
@synthesize composeBarView = _composeBarView;
@synthesize container = _container;
@synthesize arrPfCommentsEachPost = _arrPfCommentsEachPost;
@synthesize arrPfContentsPost = _arrPfContentsPost;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _arrPfContentsPost = [[NSMutableArray alloc] initWithArray:[Common arrContentPosts]];
    _arrPfCommentsEachPost = [[NSMutableArray alloc] initWithArray:[Common arrComments]];
    
    _arrPfData = [[[NSMutableArray alloc] init] mutableCopy];
    _tblMyProfile.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggleMPf:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggleMPf:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    _btHideKeyBoard.hidden = YES;
    selectedIndexPath = -1;
    addCommentAtIndex = -1;
    pageIndex = 1;
    totalPage = 0;
    
    _container = [self container];
    [_container addSubview:[self composeBarView]];
    [self.view addSubview:_container];
    _container.hidden = YES;
    
    [self callWSGetMyProfile];
}

- (void)viewWillAppear:(BOOL)animated {
    
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

#pragma mark - CALL WS
- (void) callWSGetMyProfile {
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"access_token":[UserDefault user].token,
                                            @"id":[UserDefault user].u_id,
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_GET_PROFILE([UserDefault user].u_id)));
    [manager GET:URL_SERVER_API(API_GET_PROFILE([UserDefault user].u_id)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideLoadingViewGlobal];
        NSLog(@"respone: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                if (success) {
                    self.dicProfile = object[@"data"][@"user"];
                    if (_arrPfData) {
                        pageIndex = 1;
                        totalPage = 0;
                        [_arrPfData removeAllObjects];
                    }
                    [self callWSPfGetPost:dicProfile[@"id"]];
                }
            }];
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

- (void) callWSPfGetPost:(NSString *) strId {
    //[Common showLoadingViewGlobal:nil];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"access_token":[UserDefault user].token,
                                            @"id":strId,
                                            @"page":@(pageIndex),
                                            @"limit":@(LIMIT_LIST_POST),
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_GET_POST_OF_USER(strId)));
    [manager GET:URL_SERVER_API(API_GET_POST_OF_USER(strId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideLoadingViewGlobal];
        NSLog(@"respone: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                if (success) {
                    if (object[@"data"][@"items"] != nil) {
                        if (object[@"data"][@"total"] != nil) {
                            totalPage = [object[@"data"][@"total"] intValue];
                        }
                        for (int i = 0; i < [object[@"data"][@"items"] count]; i++) {
                            
                            //TODO: Remove
                            /*
                            object[@"data"][@"items"][i][@"content"] = @"jkjlksd lskdjflksj lskdjlskjd sldkjlsdj lksjd lsldjlskjdlskjdlskjdlsjd lksjdlksjdlf;alsdjf lskdjlskdjksjd lskdjls;alskdj slkjdlksjdlkjd";
                            object[@"data"][@"items"][i][@"media"] = @[
                                                                       @{
                                                                           @"id" : @"5510371558e6934c2b8b45db",
                                                                           @"src" : @"http://a22f7e7bcfc871686260-0582f3ea2fe1b14fc085b1e626749136.r10.cf2.rackcdn.com/5510371558e6934c2b8b45db.jpg",
                                                                           @"thumb" : @"http://a22f7e7bcfc871686260-0582f3ea2fe1b14fc085b1e626749136.r10.cf2.rackcdn.com/5510371558e6934c2b8b45db_sm.jpg",
                                                                           @"type" : @"photo"
                                                                           },
                                                                       @{
                                                                           @"id" : @"5510371658e693712b8b45f8",
                                                                           @"src" : @"http://a22f7e7bcfc871686260-0582f3ea2fe1b14fc085b1e626749136.r10.cf2.rackcdn.com/5510371658e693712b8b45f8.jpg",
                                                                           @"thumb" : @"http://a22f7e7bcfc871686260-0582f3ea2fe1b14fc085b1e626749136.r10.cf2.rackcdn.com/5510371658e693712b8b45f8_sm.jpg",
                                                                           @"type" : @"photo"
                                                                           },
                                                                       @{
                                                                           @"id" : @"5510371758e693e4348b45c7",
                                                                           @"src" : @"http://a22f7e7bcfc871686260-0582f3ea2fe1b14fc085b1e626749136.r10.cf2.rackcdn.com/5510371758e693e4348b45c7.jpg",
                                                                           @"thumb" : @"http://a22f7e7bcfc871686260-0582f3ea2fe1b14fc085b1e626749136.r10.cf2.rackcdn.com/5510371758e693e4348b45c7_sm.jpg",
                                                                           @"type" : @"photo"
                                                                           },
                                                                       @{
                                                                           @"id" : @"5510371b58e6934e2b8b45e2",
                                                                           @"src" : @"http://a22f7e7bcfc871686260-0582f3ea2fe1b14fc085b1e626749136.r10.cf2.rackcdn.com/5510371b58e6934e2b8b45e2.mp4",
                                                                           @"thumb" : @"http://a22f7e7bcfc871686260-0582f3ea2fe1b14fc085b1e626749136.r10.cf2.rackcdn.com/5510371b58e6934e2b8b45e2.jpg",
                                                                           @"type" : @"video"
                                                                           }];
*/
                            
                            
                            [_arrPfData addObject:object[@"data"][@"items"][i]];
                        }
                        if ([_arrPfData count] > 0) {
                            [_tblMyProfile reloadData];
                        }
                    }
                }
            }];
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

- (void) callWSAddComment:(NSString *)postId andTextCm:(NSString *) strComment andIndexPath:(NSIndexPath *)indexPath {
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"access_token":[UserDefault user].token,
                                            @"content":strComment,
                                            @"id":postId,
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_COMMENT_FOR_A_POST(postId)));
    [manager POST:URL_SERVER_API(API_COMMENT_FOR_A_POST(postId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideNetworkActivityIndicator];
        NSLog(@"respone: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            //Reload cell
            [[_arrPfData objectAtIndex:indexPath.row][@"comment"][@"items"] insertObject:responseObject[@"data"][@"comment"] atIndex:0];
            NSIndexPath *indexPNew = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
            int totalCm = [[_arrPfData objectAtIndex:indexPath.row][@"comment"][@"total"] intValue];
            totalCm++;
            [_arrPfData objectAtIndex:indexPath.row][@"comment"][@"total"] = @(totalCm);
            [_tblMyProfile reloadRowsAtIndexPaths:@[indexPNew]
                                   withRowAnimation:UITableViewRowAnimationFade];
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

- (void) callWSPfLikeDislikePost:(NSString *)postId andLikeDislike:(NSString *) strLike andIndexPath:(NSIndexPath *)indexPath {
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"access_token":[UserDefault user].token,
                                            @"type":strLike,
                                            @"id":postId,
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_LIKE_DISLIKE_POST(postId)));
    [manager POST:URL_SERVER_API(API_LIKE_DISLIKE_POST(postId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideNetworkActivityIndicator];
        NSLog(@"respone: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                [_arrPfData objectAtIndex:indexPath.row][@"like"][@"total"] = object[@"data"][@"post"][@"like"][@"total"];
                [_arrPfData objectAtIndex:indexPath.row][@"dislike"][@"total"] = object[@"data"][@"post"][@"dislike"][@"total"];
                NSIndexPath *indexPNew = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
                [_tblMyProfile reloadRowsAtIndexPaths:@[indexPNew]
                                       withRowAnimation:UITableViewRowAnimationFade];
            }];
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

- (void) callWSLoadComments:(NSString *) postId andPage:(int)page andLimit:(int)limit {
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"access_token":[UserDefault user].token,
                                            @"id":postId,
                                            @"page":@(page),
                                            @"limt":@(limit),
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_COMMENT_FOR_A_POST(postId)));
    [manager GET:URL_SERVER_API(API_COMMENT_FOR_A_POST(postId)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideNetworkActivityIndicator];
        NSLog(@"respone: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            //Reload cell
            NSLog(@"Comment thanh cong!");
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

- (void) callWSChangeNameProfile:(NSString *)strName {
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"access_token":[UserDefault user].token,
                                            @"name":strName,
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_CHANGE_NAME_MY_PROFILE));
    [manager PUT:URL_SERVER_API(API_CHANGE_NAME_MY_PROFILE) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideLoadingViewGlobal];
        NSLog(@"respone: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                if (success) {
                    self.dicProfile = object[@"data"][@"user"];
                }
            }];
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

- (void) callWSUploadImageAvatar:(UIImage *)imgData{
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSData *mediaData;
    NSString *strTypeMedia = @"image/jpeg";
    NSString *strNameMedia = @"photo.jpg";
    if ([[imgData class] isSubclassOfClass:[UIImage class]]) {
        mediaData = UIImageJPEGRepresentation((UIImage *)imgData, 0.7);
    } else return;
    NSDictionary *sizeParam = @{@"access_token":[UserDefault user].token,
                                };
    NSLog(@"access token: %@ - %@",URL_SERVER_API(API_CHANGE_AVATAR_MY_PROFILE), [UserDefault user].token);
    
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperation *op = [manager POST:URL_SERVER_API(API_CHANGE_AVATAR_MY_PROFILE) parameters:sizeParam constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:mediaData name:@"file" fileName:strNameMedia mimeType:strTypeMedia];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideNetworkActivityIndicator];
        [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
            if (success) {
                myProfileCell *cellPf = (myProfileCell *)[_tblMyProfile cellForRowAtIndexPath:indexPathNameAvatar];
                cellPf.imgViewAvatar.image = imgData;
                self.dicProfile = object[@"data"][@"user"];
                [UserDefault user].avatar = object[@"data"][@"user"][@"avatar"];
                [UserDefault update];
            }
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
    }];
    [op start];
}



#pragma mark - FUNCTIONS
- (UIView *) returnCommentsView:(NSArray *) arrComments andLoadAll:(BOOL) isAll andFrom:(NSString *) strFrom{
    
    int widthCm = WIDTH_COMMENT_AREA_POST_LIST - 14;
    if ([Common checkIphoneVersion:@"6"]) {
        widthCm = WIDTH_COMMENT_AREA_POST_LIST6;
    }
    if ([Common checkIphoneVersion:@"6P"]) {
        widthCm = WIDTH_COMMENT_AREA_POST_LIST6P - 10;
    }
    
    //Get backgound color
    UIColor *bgColor;
    bgColor = [UIColor whiteColor];
    if ([strFrom isEqualToString:@"post"]) {
        bgColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    }
    if ([strFrom isEqualToString:@"profile"]) {
        bgColor = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:0.5];
    }
    
    //Change width again
    widthCm += 20;
    if ([Common checkIphoneVersion:@"6"]) {
        widthCm -= 10;
    }
    
    
    UIView *viewT = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthCm, 0)];
    float y = 0.0;
    int length = 1;
    if(isAll) {
        length = [arrComments count];
    } else {
        if ([arrComments count] <= COUNT_START_MPF_COMMENTS) {
            length = [arrComments count];
        }
    }
    
    for (int i = 0; i < length; i++) {
        NSString *strT = [arrComments objectAtIndex:i][@"content"];
        float heightT = [Common getHeightOfText:widthCm andText:strT andFont:FONT_TEXT_COMMENTS];
        TTTAttributedLabel *lbl = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, y, widthCm, heightT + 10)];
        lbl.backgroundColor = bgColor;
        lbl.layer.borderColor = (__bridge CGColorRef)(bgColor);
        lbl.layer.borderWidth = 1.0;
        lbl.layer.cornerRadius = 2.0;
        lbl.layer.masksToBounds = YES;
        lbl.textInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        
        lbl.font = FONT_TEXT_COMMENTS;
        if ([strFrom isEqualToString:@"post"]) {
            lbl.textColor = [UIColor lightGrayColor];
        } else {
            lbl.textColor = [UIColor grayColor];
        }
        lbl.numberOfLines = 20;
        lbl.text = strT;
        
        y+= heightT + 17;
        
        [viewT addSubview:lbl];
    }
    
    CGRect frameT = viewT.frame;
    frameT.size.height = y;
    viewT.frame = frameT;
    
    return viewT;
}

#pragma mark - COMPOSE POST
- (void)keyboardWillToggleMPf:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    CGRect startFrame;
    CGRect endFrame;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]    getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]        getValue:&startFrame];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]          getValue:&endFrame];
    
    NSInteger signCorrection = 1;
    if (startFrame.origin.y < 0 || startFrame.origin.x < 0 || endFrame.origin.y < 0 || endFrame.origin.x < 0)
        signCorrection = -1;
    
    CGFloat widthChange  = (endFrame.origin.x - startFrame.origin.x) * signCorrection;
    CGFloat heightChange = (endFrame.origin.y - startFrame.origin.y) * signCorrection;
    
    CGFloat sizeChange = UIInterfaceOrientationIsLandscape([self interfaceOrientation]) ? widthChange : heightChange;
    
    
    CGRect newContainerFrame = [[self container] frame];
    newContainerFrame.size.height += sizeChange;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [[self container] setFrame:newContainerFrame];
                     }
                     completion:NULL];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    [composeBarView resignFirstResponder];
    _container.hidden = YES;
    
    //Call WS add comment
    [self callWSAddComment:[_arrPfData objectAtIndex:addCommentAtIndex][@"id"] andTextCm:composeBarView.textView.text andIndexPath:[NSIndexPath indexPathForRow:addCommentAtIndex inSection:0]];
}

- (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView {
    
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
   willChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
              duration:(NSTimeInterval)duration
        animationCurve:(UIViewAnimationCurve)animationCurve
{
    
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
{
    
}


//@synthesize container = _container;
- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [Common widthScreen], [Common heightScreen])];
        [_container setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        _container.backgroundColor = [UIColor clearColor];
        [_container addSubview:_btHideKeyboard];
    }
    
    return _container;
}


- (PHFComposeBarView *) composeBarView {
    if (!_composeBarView) {
        NSLog(@"%f  %f", kInitialViewFrameMPFInput.size.height, [Common heightScreen]);
        CGRect frame = CGRectMake(0.0f,
                                  [Common heightScreen] - PHFComposeBarViewInitialHeight,
                                  [Common widthScreen],
                                  PHFComposeBarViewInitialHeight);
        _composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
        [_composeBarView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
        _composeBarView.buttonTintColor = COLOR_BUTTON_POST_SEND;
        [_composeBarView.textView setFont:FONT_TEXT_POST];
        [_composeBarView setMaxCharCount:160];
        [_composeBarView setMaxLinesCount:5];
        [_composeBarView setButtonTitle:@"Post"];
        [_composeBarView setPlaceholder:@"Type something..."];
        [_composeBarView.button setTitleColor:COLOR_BUTTON_POST_SEND forState:UIControlStateDisabled];
        _composeBarView.maxCharCount = 0;
        [_composeBarView setDelegate:self];
    }
    
    return _composeBarView;
}

#pragma mark - TABLE DELEAGATE
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrPfData count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 400;
    }
    
    if (indexPath.row > 0) {
        NSDictionary *obj = [_arrPfData objectAtIndex:indexPath.row-1];
        float heightOfRow = 150;
        
        if ([(NSArray *)obj[@"media"] count] > 0) {
            heightOfRow += HEIGHT_SLIDE_IMAGE_POST_LIST;
        }
        
        int widthConten = WIDTH_CONTENT_AREA_POST_LIST;
        widthConten -= 5;
        if ([Common checkIphoneVersion:@"6"]) {
            widthConten = 340;
        }
        if ([Common checkIphoneVersion:@"6P"]) {
            widthConten = 379;
        }
        widthConten+=10;
        heightOfRow += [Common getHeightOfText:widthConten andText:[_arrPfData objectAtIndex:indexPath.row-1][@"content"] andFont:FONT_TEXT_CONTENT_POST];
        
        if (indexPath.row == selectedIndexPath) {
            heightOfRow += [self returnCommentsView:obj[@"comment"][@"items"] andLoadAll:true andFrom:@"post"].frame.size.height;
        } else {
            if ([obj[@"comment"][@"total"] integerValue] > 0) {
                heightOfRow += [self returnCommentsView:obj[@"comment"][@"items"] andLoadAll:false andFrom:@"post"].frame.size.height;
            }
        }
        
        NSLog(@"index: %ld", (long)indexPath.row);
        NSLog(@"selected: %d", selectedIndexPath);
        return heightOfRow;
    }
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        myProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myProfileCellId" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([myProfileCell class]) owner:nil options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.layoutMargins = UIEdgeInsetsMake(0, 1000, 0, 0);
        cell.preservesSuperviewLayoutMargins = NO;
        [Common circleImageView:cell.imgViewAvatar];
        [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:self.dicProfile[@"avatar"]]];
        NSLog(@"cell Avatar: %@", [NSURL URLWithString:self.dicProfile[@"avatar"]]);
        cell.tfNamePf.delegate = self;
        cell.tfNamePf.userInteractionEnabled = NO;
        NSString *strName = [NSString stringWithFormat:@"%@", self.dicProfile[@"name"]];
        if (![strName isEqual:@"(null)"]) {
            cell.tfNamePf.text = strName;
        }
        if ([Common checkIphoneVersion:@"6"]) {
            [Common changeX:cell.viewInforProfile andX:30];
        }
        if ([Common checkIphoneVersion:@"6P"]) {
            [Common changeX:cell.viewInforProfile andX:50];
        }
        cell.btChangePicture.tag = indexPath.row;
        [cell.btChangePicture addTarget:self action:@selector(actionChangeAvatar:) forControlEvents:UIControlEventTouchUpInside];
        cell.btEditName.tag = indexPath.row;
        [cell.btEditName addTarget:self action:@selector(actionEditName:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    }
    
    if (indexPath.row > 0) {
        
        int MARGIN_RIGHT_ALL_CELL = 13;
        
        myProfilePostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myProfilePostCellId" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([myProfilePostCell class]) owner:nil options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.btAddComment.tag = indexPath.row - 1;
        [cell.btAddComment addTarget:self action:@selector(actionAddComment:) forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary *obj = [_arrPfData objectAtIndex:indexPath.row-1];
        
        /*** POSTED AWAY KM ***/
        CLLocationCoordinate2D userLocation = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@",[UserDefault user].strLat, [UserDefault user].strLong]];
        CLLocationCoordinate2D postLocation = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@",obj[@"location"][@"latitude"], obj[@"location"][@"longitude"]]];
        float kmAway = [Common kilometersfromPlace:userLocation andToPlace:postLocation];

        
        if (kmAway > 1) {
            cell.lblPostedAway.text = [NSString stringWithFormat:@"Posted %.0f kms away", kmAway];
        } else {
            cell.lblPostedAway.text = [NSString stringWithFormat:@"Posted %.0f km away", kmAway];
        }
        
        /* Time Ago... */
        NSDate *created_date = [NSDate dateWithTimeIntervalSince1970:[obj[@"created_at"] doubleValue]];
        NSString *str_created_date = [created_date timeAgo];
        if ([Common checkIphoneVersion:@"6"]) {
            [Common changeX:cell.lblTimeAgo andX:235];
        } else if([Common checkIphoneVersion:@"6P"]) {
            [Common changeX:cell.lblTimeAgo andX:275];
        } else {
            [Common changeX:cell.lblTimeAgo andX:185];
        }
        cell.lblTimeAgo.text = str_created_date;
        
        
        /**** POST CONTENT *****/
        int widthConten = WIDTH_CONTENT_AREA_POST_LIST;
        widthConten -= 5;
        if ([Common checkIphoneVersion:@"6"]) {
            widthConten = 340;
        }
        if ([Common checkIphoneVersion:@"6P"]) {
            widthConten = 379;
        }
        
        
        float height_content_post = [Common getHeightOfText:widthConten andText:obj[@"content"] andFont:FONT_TEXT_CONTENT_POST];
        [Common changeHeight:cell.lblContentPost andHeight:height_content_post];
        [Common changeY:cell.lblContentPost andY:40];
        [Common changeWidth:cell.lblContentPost andWidth:widthConten];
        cell.lblContentPost.text = obj[@"content"];
        
        /*** IMAGE SLIDE ***/
        int height_img_slide_area = 0;
        NSArray *arrayImgSlide = obj[@"media"];
        if ([arrayImgSlide count] > 0) {
            
            cell.viewBoundScrollImgMPF.hidden = NO;
            cell.scrollViewMPF.hidden = NO;
            //Remove subview slide
            NSArray *subViewsSlide = [cell.scrollViewMPF subviews];
            for (UIView *v in subViewsSlide) {
                [v removeFromSuperview];
            }
            
            
            height_img_slide_area = HEIGHT_SLIDE_IMAGE_POST_LIST;
            //Change Position Y
            [Common changeY:cell.viewBoundScrollImgMPF andY:50 + height_content_post];
            [Common changeY:cell.scrollViewMPF andY:50 + height_content_post];
            
            float widthViewBoundImg = tableView.frame.size.width;
            CGRect frameT = cell.viewBoundScrollImgMPF.frame;
            frameT.size.width = widthViewBoundImg;
            cell.viewBoundScrollImgMPF.frame = frameT;
            
            frameT = cell.scrollViewMPF.frame;
            frameT.size.width = widthViewBoundImg - 30;
            cell.scrollViewMPF.frame = frameT;
            [Common changeX:cell.scrollViewMPF andX:MARGIN_RIGHT_ALL_CELL];
            cell.scrollViewMPF.clipsToBounds = NO;
            cell.scrollViewMPF.pagingEnabled = YES;
            cell.scrollViewMPF.showsHorizontalScrollIndicator = NO;
            
            CGFloat contentOffset = 0.0f;
            for (int i=0; i < [arrayImgSlide count]; i++) {
                NSDictionary *objImg = [arrayImgSlide objectAtIndex:i];
                CGRect imageViewFrame = CGRectMake(contentOffset, 0.0f, cell.scrollViewMPF.frame.size.width, cell.scrollViewMPF.frame.size.height);
                UIView *imageView = [[UIView alloc] initWithFrame:imageViewFrame];
                imageView.backgroundColor = [UIColor clearColor];
                
                int spaceScroll = 5;
                CGRect frameImageButton = CGRectMake(spaceScroll, 0, imageView.frame.size.width - (spaceScroll * 2) + 5, imageView.frame.size.height);
                ASNetworkImageNode *imageViewChild = [[ASNetworkImageNode alloc] init];
                imageViewChild.frame = frameImageButton;
                imageViewChild.view.backgroundColor = [UIColor lightGrayColor];
                imageViewChild.URL = [NSURL URLWithString:objImg[@"thumb"]];
                
                //[imageViewChild setImageWithURL:[NSURL URLWithString:objImg[@"thumb"]] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                imageViewChild.contentMode = UIViewContentModeScaleAspectFill;
                [imageView addSubview:imageViewChild.view];
                
                ButtonShowImageSlide *btShowImage = [[ButtonShowImageSlide alloc] initWithFrame:frameImageButton];
                NSIndexPath *indexPathNew = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
                btShowImage.indexPathCell = indexPathNew;
                btShowImage.indexImageSelected = (NSInteger)i;
                
                //if is video
                if ([objImg[@"type"] isEqualToString:@"video"]) {
                    btShowImage.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5];
                    UIImageView *imgBtPlayVideo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
                    imgBtPlayVideo.image = [UIImage imageNamed:@"btPlayVideo.png"];
                    imgBtPlayVideo.center = imageViewChild.view.center;
                    [btShowImage addSubview:imgBtPlayVideo];
                }
                
                [imageView addSubview:btShowImage];
                [btShowImage addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
                
                
                [cell.scrollViewMPF addSubview:imageView];
                contentOffset += imageView.frame.size.width;
                cell.scrollViewMPF.contentSize = CGSizeMake(contentOffset, cell.scrollViewMPF.frame.size.height);
            }
        }
        else {
            cell.viewBoundScrollImgMPF.hidden = YES;
            cell.scrollViewMPF.hidden = YES;
        }
        
        /*** VIEW LIKE COMMENT ***/
        [cell.btLike setTitleColor:COLOR_LIKE_ENABLE forState:UIControlStateNormal];
        [cell.btDislike setTitleColor:COLOR_DISLIKE_ENABLE forState:UIControlStateNormal];
        cell.btLike.tag = indexPath.row - 1;
        cell.btDislike.tag = indexPath.row - 1;
        [Common changeY:cell.viewLikeCommentsArea andY:height_content_post + height_img_slide_area + 60];
        [Common changeHeight:cell.viewLikeCommentsArea andHeight:60];
        [Common changeWidth:cell.viewLikeCommentsArea andWidth:widthConten+1];
        if ([Common checkIphoneVersion:@"6"]) {
            
        }
        if ([Common checkIphoneVersion:@"6P"]) {
            
        }
        
        [cell.btLike addTarget:self action:@selector(actionLikePost:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btDislike addTarget:self action:@selector(actionDislikePost:) forControlEvents:UIControlEventTouchUpInside];
        cell.lblCountComment.text = [NSString stringWithFormat:@"Comments(%d)", [obj[@"comment"][@"total"] integerValue]];
        
        int numLike = [obj[@"like"][@"total"] intValue];
        int numDislike = [obj[@"dislike"][@"total"] intValue];
        cell.lblNumberLikes.text = [NSString stringWithFormat:@"%d", numLike];
        cell.lblNumberDislikes.text = [NSString stringWithFormat:@"%d", numDislike];
        
        if (numLike > 0 || numDislike > 0) {
            [Common changeWidth:cell.viewColorLike andWidth:(float)numLike/((float)numLike + (float)numDislike) * cell.viewColorLikeTotal.frame.size.width];
        } else {
            [Common changeWidth:cell.viewColorLike andWidth:cell.viewColorLikeTotal.frame.size.width/2];
        }
        
        
        /*** VIEW COMMENT ***/
        cell.lblCountComment.hidden = YES;
        int total_cm = [obj[@"comment"][@"total"] integerValue];
        if (total_cm > 0) {
            cell.viewComment.hidden = NO;
            [Common changeY:cell.viewComment andY:30+height_content_post+height_img_slide_area+90];
            [Common changeWidth:cell.viewComment andWidth:widthConten];
            
            if (indexPath.row == selectedIndexPath) {
                cell.btShowAllCm.hidden = YES;
                cell.lblCountComment.hidden = YES;
            } else {
                cell.btShowAllCm.hidden = NO;
                cell.lblCountComment.hidden = NO;
            }
            
            cell.btShowAllCm.tag = indexPath.row;
            [cell.btShowAllCm addTarget:self action:@selector(actionShowAll:) forControlEvents:UIControlEventTouchUpInside];
            
            /*** ADD COMMENT ***/
            //Remove subview comment
            NSArray *subViewsComment = [cell.viewComment subviews];
            for (UIView *v in subViewsComment) {
                if (![[v class] isSubclassOfClass:[UIButton class]]) {
                    [v removeFromSuperview];
                }
            }
            
            BOOL isLoadAllCm = false;
            if (selectedIndexPath == indexPath.row) {
                isLoadAllCm = true;
            }
            UIView *viewCm = [self returnCommentsView:obj[@"comment"][@"items"] andLoadAll:isLoadAllCm andFrom:@"profile"];
            [cell.viewComment addSubview:viewCm];
            if (total_cm > COUNT_START_MPF_COMMENTS && indexPath.row != selectedIndexPath) {
                cell.btShowAllCm.hidden = NO;
                cell.lblCountComment.hidden = NO;
                [Common changeHeight:cell.viewComment andHeight:(viewCm.frame.size.height + 20)];
            } else {
                cell.btShowAllCm.hidden = YES;
                cell.lblCountComment.hidden = YES;
                [Common changeHeight:cell.viewComment andHeight:(viewCm.frame.size.height)];
            }
        } else {
            cell.viewComment.hidden = YES;
        }
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 0) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    
    if (indexPath.row ==  [_arrPfData count] - 1) {
        if (totalPage > [_arrPfData count]) {
            pageIndex++;
            [self callWSPfGetPost:dicProfile[@"id"]];
        }
    }
}

-(void)viewDidLayoutSubviews
{
    if ([_tblMyProfile respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tblMyProfile setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_tblMyProfile respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tblMyProfile setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITextfield Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    myProfileCell *cellPf = (myProfileCell *)[_tblMyProfile cellForRowAtIndexPath:indexPathNameAvatar];
    if (cellPf != nil) {
        _btHideKeyBoard.hidden = YES;
        cellPf.tfNamePf.userInteractionEnabled = NO;
        if (cellPf.tfNamePf.text.length > 0) {
            strNameTemp = cellPf.tfNamePf.text;
            [self callWSChangeNameProfile:cellPf.tfNamePf.text];
        } else {
            cellPf.tfNamePf.text = strNameTemp;
        }
        [cellPf.tfNamePf resignFirstResponder];
    }
    return YES;
}

#pragma mark - SCROLL DELEGATE
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

#pragma mark - ACTION ON POST CELL
- (void)actionShowAll:(id) sender {
    if (selectedIndexPath > -1) {
        NSIndexPath *indexPathPrevious = [NSIndexPath indexPathForItem:selectedIndexPath inSection:0];
        selectedIndexPath = -1;
        [_tblMyProfile reloadRowsAtIndexPaths:@[indexPathPrevious]
                               withRowAnimation:UITableViewRowAnimationFade];
    }
    
    UIButton *bt = (UIButton *) sender;
    selectedIndexPath = bt.tag;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectedIndexPath inSection:0];
    [_tblMyProfile reloadRowsAtIndexPaths:@[indexPath]
                           withRowAnimation:UITableViewRowAnimationFade];
}

- (void) actionAddComment:(id)sender {
    UIButton *bt = (UIButton *) sender;
    NSLog(@"bt tag: %d", bt.tag);
    addCommentAtIndex = bt.tag;
    _composeBarView.textView.text = @"";
    _container.hidden = NO;
    [_composeBarView.textView becomeFirstResponder];
    [_composeBarView setUtilityButtonImage:nil];
}

- (void) actionLikePost:(id)sender {
    UIButton *bt = (UIButton *) sender;
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:bt.tag inSection:0];
    [self callWSPfLikeDislikePost:[_arrPfData objectAtIndex:bt.tag][@"id"] andLikeDislike:@"like" andIndexPath:indexP];
}

- (void) actionDislikePost:(id)sender {
    UIButton *bt = (UIButton *) sender;
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:bt.tag inSection:0];
    [self callWSPfLikeDislikePost:[_arrPfData objectAtIndex:bt.tag][@"id"] andLikeDislike:@"dislike" andIndexPath:indexP];
}

- (void) showImage:(id) sender {
    
    ButtonShowImageSlide *bt = (ButtonShowImageSlide *)sender;
    NSLog(@"Dang chon cell: %d and %d", bt.indexPathCell.row, (int)bt.indexImageSelected);
    
    NSArray *arrMedia = [_arrPfData objectAtIndex:bt.indexPathCell.row][@"media"];
    if ([arrMedia count] > 0 && [arrMedia objectAtIndex:(int)bt.indexImageSelected]!=nil) {
        NSDictionary *objSelected = [arrMedia objectAtIndex:(int)bt.indexImageSelected];
        if ([objSelected[@"type"] isEqualToString:@"video"]) {
            if (!_moviePlayer) {
                _moviePlayer = [[MPMoviePlayerViewController alloc] init];
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:MPMoviePlayerPlaybackDidFinishNotification
                                                          object:_moviePlayer.moviePlayer];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(donefinishedPlayVideo:)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification
                                                       object:_moviePlayer.moviePlayer];
            
            [_moviePlayer.moviePlayer stop];
            _moviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
            [_moviePlayer.moviePlayer setContentURL:[NSURL URLWithString:objSelected[@"src"]]];
            
            _moviePlayer.moviePlayer.shouldAutoplay=YES;
            [_moviePlayer.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
            
            [self.view addSubview:_moviePlayer.view];
            [_moviePlayer.moviePlayer play];
            
        } else {
            //Choose array has only images
            NSMutableArray *photos = [[NSMutableArray alloc] init];
            //NSMutableArray *thumbs = [[NSMutableArray alloc] init];
            BOOL displayActionButton = NO;
            BOOL displaySelectionButtons = NO;
            BOOL displayNavArrows = NO;
            BOOL enableGrid = NO;
            BOOL startOnGrid = NO;
            int indexRealSelectedImg = (int)bt.indexImageSelected;
            
            for (int i = 0; i < [arrMedia count]; i++) {
                NSDictionary *objImg = [arrMedia objectAtIndex:i];
                if ([objImg[@"type"] isEqualToString:@"video"]) {
                    indexRealSelectedImg--;
                }
            }
            
            for (int i = 0; i < [arrMedia count]; i++) {
                NSDictionary *objImg = [arrMedia objectAtIndex:i];
                if ([objImg[@"type"] isEqualToString:@"photo"]) {
                    [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:objImg[@"src"]]]];
                }
            }
            
            self.photos = photos;
            //self.thumbs = thumbs;
            // Create browser
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = displayActionButton;
            browser.displayNavArrows = displayNavArrows;
            browser.displaySelectionButtons = displaySelectionButtons;
            browser.alwaysShowControls = displaySelectionButtons;
            browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            browser.wantsFullScreenLayout = YES;
#endif
            browser.enableGrid = enableGrid;
            browser.startOnGrid = startOnGrid;
            browser.enableSwipeToDismiss = YES;
            [browser setCurrentPhotoIndex:indexRealSelectedImg];
            
            // Reset selections
            if (displaySelectionButtons) {
                _selections = [NSMutableArray new];
                for (int i = 0; i < photos.count; i++) {
                    [_selections addObject:[NSNumber numberWithBool:NO]];
                }
            }
            
            // Show Modal
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nc animated:YES completion:nil];
            
            
            // Test reloading of data after delay
            double delayInSeconds = 3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            });
            
        }
        
    }
    
}

#pragma mark - ACTION
- (IBAction)actionHideKeyboard:(id)sender {
    [_composeBarView resignFirstResponder];
    _container.hidden = YES;
}

- (IBAction)actionHideKeyBoard:(id)sender {
    myProfileCell *cellPf = (myProfileCell *)[_tblMyProfile cellForRowAtIndexPath:indexPathNameAvatar];
    if (cellPf != nil) {
        _btHideKeyBoard.hidden = YES;
        cellPf.tfNamePf.userInteractionEnabled = NO;
        [cellPf.tfNamePf resignFirstResponder];
        cellPf.tfNamePf.text = strNameTemp;
    }
}

- (IBAction)actionBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionChangeAvatar:(id)sender {
    UIButton *bt = (UIButton *)sender;
    indexPathNameAvatar = [NSIndexPath indexPathForRow:bt.tag inSection:0];
    
    UIActionSheet *actionSheetRightMenu = [[UIActionSheet alloc] initWithTitle:APP_NAME delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    actionSheetRightMenu.tag = 1;
    [actionSheetRightMenu showInView:self.view];
}

- (void)actionEditName:(id)sender {
    UIButton *bt = (UIButton *)sender;
    indexPathNameAvatar = [NSIndexPath indexPathForRow:bt.tag inSection:0];
    myProfileCell *cellPf = (myProfileCell *)[_tblMyProfile cellForRowAtIndexPath:indexPathNameAvatar];
    if (cellPf != nil) {
        [_tblMyProfile setContentOffset:CGPointMake(0, 150) animated:YES];
        cellPf.tfNamePf.userInteractionEnabled = YES;
        strNameTemp = cellPf.tfNamePf.text;
        _btHideKeyBoard.hidden = NO;
        [cellPf.tfNamePf becomeFirstResponder];
    }
}

#pragma mark - CAMERA DELEGATE
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate setIsChoosing:(BOOL) isChoosing
{
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if (isChoosing) {
        //cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    } else {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        cameraUI.mediaTypes =
        [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    }
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;
    cameraUI.videoQuality = UIImagePickerControllerQualityTypeMedium;
    cameraUI.videoMaximumDuration = 10;
    
    cameraUI.delegate = delegate;
    
    //[controller presentModalViewController: cameraUI animated: YES];
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    imageToSave = nil;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        //Save image to array TODO add
        myProfileCell *cellPf = (myProfileCell *)[_tblMyProfile cellForRowAtIndexPath:indexPathNameAvatar];
        if (cellPf != nil) {
            [self callWSUploadImageAvatar:imageToSave];
        }
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark ACTIONSHEET DELEGATE
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (actionSheet.tag) {
        case 1:
        {
            switch (buttonIndex) {
                case 0:
                {
                    [self startCameraControllerFromViewController:self usingDelegate:self setIsChoosing:NO];
                }
                    break;
                case 1:
                {
                    [self startCameraControllerFromViewController:self usingDelegate:self setIsChoosing:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Play Video Delegate
- (void) donefinishedPlayVideo:(NSNotification*)aNotification {
    [_moviePlayer.moviePlayer stop];
    [_moviePlayer.view removeFromSuperview];
    _moviePlayer = nil;
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
