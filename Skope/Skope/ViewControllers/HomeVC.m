//
//  HomeVC.m
//  Skope
//
//  Created by CHAU HUYNH on 2/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "HomeVC.h"
#import "PageContainVC.h"
#import "MessagesView.h"
CGRect const kInitialViewFrame = { 0.0f, 0.0f, 320.0f, 480.0f };
#define image_scale_default_camera 200

@interface HomeVC ()

@end

@implementation HomeVC

@synthesize delegate;

@synthesize arrDummyContents = _arrDummyContents;
@synthesize arrDummyComments = _arrDummyComments;
@synthesize arr_data_media = _arr_data_media;
@synthesize arr_data_media_temp = _arr_data_media_temp;
@synthesize composeBarView = _composeBarView;
@synthesize container = _container;
@synthesize viewComposePhoto = _viewComposePhoto;
@synthesize scrCompose = _scrCompose;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    _mapV.delegate = self;
    NSLog(@"Token: %@", [UserDefault user].token);
//    if ([[UserDefault user].isFirstTime isEqualToString:@"false"]) {
//        _btHelpScreen.hidden = YES;
//        
//    }
    [self locationCurrentInit];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    
    selectedIndexPath = -1;
    indexProcessComposePost = 0;
    isMyProfile = false;
    radiusUpdate = 1.0f;
    
    [self circleViewConfig];
    
    _arrDummyContents = [[NSMutableArray alloc] initWithArray:[Common arrContentPosts]];
    _arrDummyComments = [[NSMutableArray alloc] initWithArray:[Common arrComments]];
    _arr_data_media = [[NSMutableArray alloc] init];
    _arr_data_media_temp = [[NSMutableArray alloc] init];
    
    CGRect frRM = _viewRadiusMap.frame;
    if ([Common checkIphoneVersion:@"5"] || [Common checkIphoneVersion:@"5S"]) {
        frRM.size.width = 220;
        frRM.size.height = 220;
    }
    
    if ([Common checkIphoneVersion:@"6P"]) {
        frRM.size.width = 300;
        frRM.size.height = 300;
        frRM.origin.x -= 10;
        frRM.origin.y += 40;

    }
    
    if ([Common checkIphoneVersion:@"6"]) {
        frRM.size.width = 260;
        frRM.size.height = 260;
        frRM.origin.x -= 4;
        frRM.origin.y += 40;
        
    }
    
    _viewRadiusMap.frame = frRM;
    
    _viewHomeLeft.hidden = YES;
    _viewHomeRight.hidden = YES;
    _viewUsersDetail.hidden = YES;
    _scrUsersDetail.scrollEnabled = YES;
    _scrUsersDetail.contentSize = CGSizeMake(300, 700);
    
    _viewTakeOrChooseExisting.hidden = YES;
    
    _tblUsers.backgroundColor = [UIColor clearColor];
    _tblUsers.opaque = NO;
    _tblUsers.backgroundView = nil;
    
    _tblPosted.backgroundColor = [UIColor clearColor];
    _tblPosted.opaque = NO;
    _tblPosted.backgroundView = nil;
    
    _imgAvatarUsersDetail.image = [UIImage imageNamed:@"avatar.jpg"];
    [Common circleImageView:_imgAvatarUsersDetail];
    [Common circleImageView:_mapV];
   
    [self.view bringSubviewToFront:_viewHomeLeft];
    [self.view bringSubviewToFront:_viewHomeRight];
    [self.view bringSubviewToFront:_viewUsersDetail];
    
    _container = [self container];
    [_container addSubview:[self composeBarView]];
    [self.view addSubview:_container];
    _container.hidden = YES;
    
    //Set icon my profile FB
    [Common circleImageView:_btGoMyProfile];
    
    
    [self fillDataToProfile];
    [self.view addSubview:_viewTakeOrChooseExisting];
    [self.view bringSubviewToFront:_viewTakeOrChooseExisting];
    [_viewTakeOrChooseExisting setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7]];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [_btGoMyProfile setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:[UserDefault user].avatar]];
}

- (void) viewDidAppear:(BOOL)animated {
    self.timerUpdateUserLocation =
    [NSTimer scheduledTimerWithTimeInterval:5
                                     target:self
                                   selector:@selector(callWSUpdateLocation)
                                   userInfo:nil
                                    repeats:YES];
   
}

- (void) viewWillDisappear:(BOOL)animated {
    if([delegate respondsToSelector:@selector(homeHideScreen:)])
    {
        [delegate homeHideScreen:radiusUpdate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark QBChatDelegate

// Chat delegate
-(void) chatDidLogin{
    // You have successfully signed in to QuickBlox Chat
    NSLog(@"chatDidLogin");
}

- (void)chatDidNotLogin{
    NSLog(@"chatDidNotLogin");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark FUNCTIONS
- (void) showProfileView:(UIView *) view {
    view.hidden = NO;
    CGRect temp = view.frame;
    temp.origin.x = 0;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         view.frame = temp;
                     }completion:^(BOOL finished){
                         
                     }];
}


- (void) showUsersView:(UIView *) view {
    view.hidden = NO;
    CGRect temp = view.frame;
    temp.origin.x = -20;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         view.frame = temp;
                     }completion:^(BOOL finished){
                         
                     }];
}

- (void) hideUsersView:(UIView *)view {
    CGRect temp = view.frame;
    temp.origin.x = -500;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionTransitionFlipFromRight
                     animations:^{
                         view.frame = temp;
                     }completion:^(BOOL finished){
                         
                     }];
}

- (void) showPostsView:(UIView *)view {
    view.hidden = NO;
    CGRect temp = view.frame;
    temp.origin.x = 20;
    if([Common checkIphoneVersion:@"6"]) {
        temp.origin.x = 50;
    }
    if([Common checkIphoneVersion:@"6P"]) {
        temp.origin.x = 68;
    }
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         view.frame = temp;
                     }completion:^(BOOL finished){
                         
                     }];
}

- (void) hidePostsView:(UIView *)view {
    CGRect temp = view.frame;
    temp.origin.x = 500;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         view.frame = temp;
                     }completion:^(BOOL finished){
                         
                     }];
}

- (void) showComposeView:(UIView *)view {
    view.hidden = NO;
    CGRect temp = view.frame;
    temp.origin.y = 285;
    if([Common checkIphoneVersion:@"5"]) {
        temp.origin.y = 370;
    }
    if([Common checkIphoneVersion:@"6"]) {
        temp.origin.y = 465;
    }
    if([Common checkIphoneVersion:@"6P"]) {
        temp.origin.y = 520;
    }
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         view.frame = temp;
                     }completion:^(BOOL finished){
                         
                     }];
}

- (void) hideComposeView:(UIView *)view {
    CGRect temp = view.frame;
    temp.origin.y = 800;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         view.frame = temp;
                     }completion:^(BOOL finished){
                         
                     }];
}

- (IBAction)actionGoUsersView:(id)sender {
    if([delegate respondsToSelector:@selector(homeListActionShowUser)])
    {
        [delegate homeListActionShowUser];
    }
}

- (IBAction)actionGoPostsView:(id)sender {
    if([delegate respondsToSelector:@selector(homeListActionShowPost)])
    {
        [delegate homeListActionShowPost];
    }
}

- (IBAction)actionBackFromUsersView:(id)sender {
    [self hideUsersView:_viewHomeLeft];
}

- (IBAction)actionBackFromPostsView:(id)sender {
    [self hidePostsView:_viewHomeRight];
}

- (IBAction)actionBackFromUsersDetail:(id)sender {
    [self hideUsersView:_viewUsersDetail];
}

- (IBAction)goProfile:(id)sender {
    
    [self performSegueWithIdentifier:@"segueToMyProfile" sender:nil];
}

- (IBAction)actionCompose:(id)sender {
    _container.hidden = NO;
    _viewComposePhoto.hidden = NO;
    [_composeBarView.textView becomeFirstResponder];
    [_composeBarView setUtilityButtonImage:[UIImage imageNamed:@"Camera"]];
    _composeBarView.button.enabled = NO;
    if([delegate respondsToSelector:@selector(homeShowKeyBoard)])
    {
        [delegate homeShowKeyBoard];
    }
}

- (IBAction)actionHideHelp:(id)sender {
    UIButton *bt = (UIButton *)sender;
    bt.hidden = YES;
    [[UserDefault user] setIsFirstTime];
    [self locationCurrentInit];
}

- (IBAction)actionTakePhotoVideo:(id)sender {
    _viewTakeOrChooseExisting.hidden = YES;
    if (_viewCameraChoosing != nil) {
        _viewCameraChoosing.hidden = YES;
    }
    if (![self startCameraControllerFromViewController:self usingDelegate:self setIsChoosing:NO]) {
        NSLog(@"Failed!");
    }
}

- (IBAction)actionChooseExisting:(id)sender {
    _viewTakeOrChooseExisting.hidden = YES;
    if (_viewCameraChoosing != nil) {
        _viewCameraChoosing.hidden = YES;
    }
    if (![self startCameraControllerFromViewController:self usingDelegate:self setIsChoosing:YES]) {
        NSLog(@"Failed!");
    }
}

- (IBAction)actionCancelTakePhoto:(id)sender {
    //_viewTakeOrChooseExisting.hidden = YES;
    if (_viewCameraChoosing != nil) {
        _viewCameraChoosing.hidden = YES;
    }
}

- (IBAction)actionHideCompose:(id)sender {
    [_composeBarView resignFirstResponder];
    _container.hidden = YES;
    _viewComposePhoto.hidden = YES;
    if([delegate respondsToSelector:@selector(homeHideKeyBoard)])
    {
        [delegate homeHideKeyBoard];
    }
}

- (IBAction)actionShowMessageList:(id)sender {
    MessagesView *messageView = [[MessagesView alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:messageView];
    //    [self.navigationController pushViewController:chatView animated:YES];
    [self presentViewController:navController animated:YES completion:nil];

}

- (void) addSwipeRight:(UIView *) view{
    UISwipeGestureRecognizer *gesSwipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightHandler:)];
    [gesSwipeR setDirection:UISwipeGestureRecognizerDirectionRight];
    [view addGestureRecognizer:gesSwipeR];
}

- (void) addSwipeLeft:(UIView *) view {
    UISwipeGestureRecognizer *gesSwipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftHandler:)];
    [gesSwipeL setDirection:UISwipeGestureRecognizerDirectionLeft];
    [view addGestureRecognizer:gesSwipeL];
}

- (void) swipeRightHandler:(UISwipeGestureRecognizer *)recognizer {
    if (_viewHomeRight.frame.origin.x == 500) {
        [self actionGoUsersView:nil];
    } else {
        [self hidePostsView:_viewHomeRight];
    }
}

- (void) swipeLeftHandler:(UISwipeGestureRecognizer *)recognizer {
    if (_viewHomeLeft.frame.origin.x == -500) {
        [self actionGoPostsView:nil];
    } else {
        [self hideUsersView:_viewHomeLeft];
    }
}

- (UIView *) returnCommentsView:(NSMutableArray *) arrComments andLoadAll:(BOOL) isAll andFrom:(NSString *) strFrom{
    
    int widthCm = WIDTH_COMMENT_AREA_POST_LIST;
    if ([Common checkIphoneVersion:@"6"]) {
        widthCm = WIDTH_COMMENT_AREA_POST_LIST6;
    }
    if ([Common checkIphoneVersion:@"6P"]) {
        widthCm = WIDTH_COMMENT_AREA_POST_LIST6P;
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
    if ([strFrom isEqualToString:@"post"]) {
        if ([Common checkIphoneVersion:@"6"]) {
            widthCm -= 50;
        }
        if ([Common checkIphoneVersion:@"6P"]) {
            widthCm -= 70;
        }
    }
    
    UIView *viewT = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthCm, 0)];
    float y = 0.0;
    int length = 1;
    if(isAll) {
        length = [arrComments count];
    }
    
    for (int i = 0; i < length; i++) {
        NSString *strT = [arrComments objectAtIndex:i];
        float heightT = [Common getHeightOfText:widthCm andText:strT andFont:FONT_TEXT_COMMENTS];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, y, widthCm, heightT + 10)];
        lbl.backgroundColor = bgColor;
        lbl.layer.borderColor = (__bridge CGColorRef)(bgColor);
        lbl.layer.borderWidth = 1.0;
        lbl.layer.cornerRadius = 2.0;
        lbl.layer.masksToBounds = YES;
        
        lbl.font = FONT_TEXT_COMMENTS;
        if ([strFrom isEqualToString:@"post"]) {
            lbl.textColor = [UIColor lightGrayColor];
        } else {
            lbl.textColor = [UIColor grayColor];
        }
        lbl.numberOfLines = 20;
        lbl.text = strT;
        
        y+= heightT + 12;
        
        [viewT addSubview:lbl];
    }
    
    CGRect frameT = viewT.frame;
    frameT.size.height = y;
    viewT.frame = frameT;
    
    return viewT;
}

- (void)actionShowAll:(id) sender {
    UIButton *bt = (UIButton *) sender;
    selectedIndexPath = bt.tag;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectedIndexPath inSection:0];
    [_tblPosted reloadRowsAtIndexPaths:@[indexPath]
                    withRowAnimation:UITableViewRowAnimationFade];
}

- (void)actionAddComment:(id) sender {
    _container.hidden = NO;
    [_composeBarView.textView becomeFirstResponder];
    [_composeBarView setUtilityButtonImage:nil];
}

- (void) fillDataToProfile {
    for (int i=0; i < 1; i++) {
        NSArray *xibviews = [[NSBundle mainBundle] loadNibNamed: @"viewCmProfile" owner: self options: nil];
        viewCmProfile *viewP = [xibviews objectAtIndex: 0];
        
        [viewP setFrame:CGRectMake(0, 360, [Common widthScreen], 200)];
        [viewP.btAddCm addTarget:self action:@selector(actionAddComment:) forControlEvents:UIControlEventTouchUpInside];
        
        //Add comments
        [viewP.viewCmArea addSubview:[self returnCommentsView:_arrDummyComments andLoadAll:true andFrom:@"profile"]];
        [_scrUsersDetail addSubview:viewP];
    }
}

- (BOOL) deleteFileTemp:(NSURL *) urlPathFile {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[urlPathFile path] error:&error];
    if (error){
        NSLog(@"error: %@", error.description);
        return false;
    }
    return true;
}

- (void) goToReloadPostList {
    if([delegate respondsToSelector:@selector(homePostDone:)])
    {
        [delegate homePostDone:true];
    }
}

- (void) createViewTakeChooseCameraBG {
    _viewCameraChoosing = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [Common widthScreen], 400)];
    _viewCameraChoosing.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    int xViewBG = 10;
    int yViewBGTakeChoose = 50;
    int yViewBGCancel = 140;
    
    if ([Common checkIphoneVersion:@"6"]) {
        xViewBG = 40;
        yViewBGTakeChoose = 60;
        yViewBGCancel = 150;
    }
    
    if ([Common checkIphoneVersion:@"6P"]) {
        xViewBG = 55;
        yViewBGTakeChoose = 70;
        yViewBGCancel = 160;
    }
    
    //Button Take A Picture
    UIButton *btTakePicture = [[UIButton alloc] initWithFrame:CGRectMake(25, 10, 250, 25)];
    [btTakePicture setTitle:@"Take Photo or Video" forState:UIControlStateNormal];
    [btTakePicture setTitleColor:FONT_COLOR_TEXT_CAMERA_CHOOSE forState:UIControlStateNormal];
    [btTakePicture.titleLabel setFont:FONT_TEXT_CAMERA_CHOOSE];
    [btTakePicture addTarget:self action:@selector(actionTakePhotoVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    //Button Choose Exist
    UIButton *btChooseExist = [[UIButton alloc] initWithFrame:CGRectMake(25, 45, 250, 25)];
    btChooseExist.titleLabel.font = FONT_TEXT_CAMERA_CHOOSE;
    [btChooseExist setTitleColor:FONT_COLOR_TEXT_CAMERA_CHOOSE forState:UIControlStateNormal];
    [btChooseExist setTitle:@"Choose Existing" forState:UIControlStateNormal];
    [btChooseExist addTarget:self action:@selector(actionChooseExisting:) forControlEvents:UIControlEventTouchUpInside];
    
    //View Take/Choose Image
    UIView *viewTakeChooseBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 80)];
    viewTakeChooseBG.backgroundColor = [UIColor whiteColor];
    [Common roundCornersOnView:viewTakeChooseBG onTopLeft:YES topRight:YES bottomLeft:YES bottomRight:YES radius:3.0];
    [viewTakeChooseBG addSubview:btTakePicture];
    [viewTakeChooseBG addSubview:btChooseExist];
    [Common changeX:viewTakeChooseBG andX:xViewBG];
    [Common changeY:viewTakeChooseBG andY:yViewBGTakeChoose];
    
    //Button Cancel
    UIButton *btCameraCancel = [[UIButton alloc] initWithFrame:CGRectMake(25, 6, 250, 25)];
    btCameraCancel.titleLabel.font = FONT_TEXT_CAMERA_CHOOSE_BOLD;
    [btCameraCancel setTitleColor:FONT_COLOR_TEXT_CAMERA_CHOOSE forState:UIControlStateNormal];
    [btCameraCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [btCameraCancel addTarget:self action:@selector(actionCancelTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    //View Button Cancel
    UIView *viewCancelBG = [[UIView alloc] initWithFrame:CGRectMake(0, 140, 300, 40)];
    viewCancelBG.backgroundColor = [UIColor whiteColor];
    [Common roundCornersOnView:viewCancelBG onTopLeft:YES topRight:YES bottomLeft:YES bottomRight:YES radius:3.0];
    [viewCancelBG addSubview:btCameraCancel];
    [Common changeX:viewCancelBG andX:xViewBG];
    [Common changeY:viewCancelBG andY:yViewBGCancel];
    
    [_viewCameraChoosing addSubview:viewTakeChooseBG];
    [_viewCameraChoosing addSubview:viewCancelBG];
}

- (void)bringTouchViewToFront
{
    UIWindow* tempWindow;
    UIView* keyboard;
    //Check each window in our application
    BOOL noKeyboard = FALSE;
    for(int i = 0; i < [[[UIApplication sharedApplication] windows] count]; i ++)
    {
        //Get a reference of the windows
        tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:i];
        
        //Get a reference of the views
        for(int j = 0; j < [tempWindow.subviews count]; j++)
        {
            keyboard = [tempWindow.subviews objectAtIndex:j];
            // check whether the view is the keyboard
            if([[keyboard description] hasPrefix:@"<UIPeripheralHostView"] == YES)
            {
                [self createViewTakeChooseCameraBG];
                [keyboard addSubview:_viewCameraChoosing];
                noKeyboard = TRUE;
                return;
            } else if([[keyboard description] hasPrefix:@"<UIInputSetContainerView"] == YES)
            {
                for(int i = 0 ; i < [keyboard.subviews count] ; i++)
                {
                    UIView* hostkeyboard = [keyboard.subviews objectAtIndex:i];
                    if([[hostkeyboard description] hasPrefix:@"<UIInputSetHost"] == YES)
                    {
                        [self createViewTakeChooseCameraBG];
                        [hostkeyboard addSubview:_viewCameraChoosing];
                        noKeyboard = TRUE;
                        return;
                    }
                }
            }
        }
        
        if (noKeyboard)
            [_viewCameraChoosing.window bringSubviewToFront:_viewCameraChoosing];
    }
}

- (void) showActionSheetOptionComposeImage {
    UIActionSheet *actionCP = [[UIActionSheet alloc] initWithTitle:APP_NAME delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo or Video", @"Choose Existing", nil];
    actionCP.tag = 1;
    [actionCP showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - WEBSERVICE
- (void) callWSGetUserPostList {
    if (CLLocationCoordinate2DIsValid(userLocation) && [[UserDefault user].token length] > 0) {
        [Common showNetworkActivityIndicator];
        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
        NSMutableDictionary *request_param = [@{
                                                @"access_token":[UserDefault user].token,
                                                @"latitude":@(userLocation.latitude),
                                                @"longitude":@(userLocation.longitude),
                                                @"distance":@(radiusUpdate),
                                                } mutableCopy];
        //NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_GET_USER_POST_LIST));
        [manager GET:URL_SERVER_API(API_GET_USER_POST_LIST) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [Common hideNetworkActivityIndicator];
            //NSLog(@"json post user: %@", (NSDictionary *)responseObject);
            if ([Common validateRespone:responseObject]) {
                dataUserPost = (NSDictionary *)responseObject;
                [self parseWSGetUserPostList:responseObject];
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

- (void) parseWSGetUserPostList:(id) jsonReturn {
    if (jsonReturn[@"data"][@"post"][@"total"]) {
        _lblNumberPosts.text = [NSString stringWithFormat:@"%@", jsonReturn[@"data"][@"post"][@"total"]];
    } else {
        _lblNumberPosts.text = @"0";
    }
    if (jsonReturn[@"data"][@"user"][@"total"]) {
        _lblNumberUsers.text = [NSString stringWithFormat:@"%@", jsonReturn[@"data"][@"user"][@"total"]];
    } else {
        _lblNumberUsers.text = @"0";
    }
}

- (void) callWSPostCompose {
        [Common showNetworkActivityIndicator];
        [Common showLoadingViewGlobal:@"Posting..."];
        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
        NSMutableDictionary *request_param = [@{
                                                @"access_token":[UserDefault user].token,
                                                @"content":_composeBarView.textView.text,
                                                @"latitude":@(userLocation.latitude),
                                                @"longitude":@(userLocation.longitude),
                                                } mutableCopy];
        NSLog(@"request_param: %@ %@ %@", request_param, URL_SERVER_API(API_COMPOSE_POST), _composeBarView.textView.text);
        [manager POST:URL_SERVER_API(API_COMPOSE_POST) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"json: %@", responseObject);
            [_composeBarView setText:@"" animated:YES];
            if ([Common validateRespone:responseObject]) {
                [self callWSGetUserPostList];
                [Common hideNetworkActivityIndicator];
                [Common hideLoadingViewGlobal];
                NSString *strPostId = responseObject[@"data"][@"post"][@"id"];
                NSLog(@"strPostId: %@", strPostId);
                NSLog(@"Count array: %d", [_arr_data_media_temp count]);
                if (strPostId && strPostId.length > 0 && [_arr_data_media_temp count] > 0) {
                    indexProcessComposePost = 0;
                    [Common showLoadingViewGlobal:@"Uploading..."];
                    for (int i = 0; i < [_arr_data_media_temp count]; i++) {
                        if ([_arr_data_media_temp objectAtIndex:i] != [NSNull null]) {
                            [self callWSUploadMedia:[_arr_data_media_temp objectAtIndex:i] andPostId:strPostId];
                        }
                    }
                } else {
                    [self goToReloadPostList];
                }
            } else {
                [_composeBarView setText:@"" animated:YES];
                [Common hideNetworkActivityIndicator];
                [Common hideLoadingViewGlobal];
                if ([Common validateAuthenFailed:responseObject]) {
                    [APP_DELEGATE setRootViewLogoutWithCompletion:^{
                            
                    }];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [_composeBarView setText:@"" animated:YES];
            [Common hideLoadingViewGlobal];
        }];
        
}

- (void) callWSUploadMedia:(id) object andPostId:(NSString *)postId{
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSData *mediaData;
    NSString *strTypeMedia = @"image/jpeg";
    NSString *strNameMedia = @"photo.jpg";
    
    if ([[object class] isSubclassOfClass:[NSURL class]]) {
        strTypeMedia = @"video/mp4";
        strNameMedia = @"video.mp4";
        NSLog(@"URL: %@", [(NSURL *)object path]);
        mediaData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[(NSURL *)object path]]];
    } else if ([[object class] isSubclassOfClass:[UIImage class]]) {
        mediaData = UIImageJPEGRepresentation((UIImage *)object, 0.5);
    } else return;
    
    NSDictionary *sizeParam = @{@"access_token":[UserDefault user].token,
                                };
    AFHTTPRequestOperation *op = [manager POST:URL_SERVER_API(API_UPLOAD_MEDIA(postId)) parameters:sizeParam constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:mediaData name:@"file" fileName:strNameMedia mimeType:strTypeMedia];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        indexProcessComposePost++;
        NSLog(@"%d %d", indexProcessComposePost, [_arr_data_media_temp count]);
        if (indexProcessComposePost == [_arr_data_media_temp count]) {
            [Common hideLoadingViewGlobal];
            [self goToReloadPostList];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        [Common hideLoadingViewGlobal];
        indexProcessComposePost++;
        NSLog(@"%d %d", indexProcessComposePost, [_arr_data_media_temp count]);
        if (indexProcessComposePost == [_arr_data_media_temp count]) {
            [self goToReloadPostList];
        }
    }];
    [op start];
}

- (void) callWSUpdateLocation {
    if (CLLocationCoordinate2DIsValid(userLocation) && [[UserDefault user].token length] > 0) {
        NSString *strStatus = @"unknow";
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
        {
            strStatus = @"background_mode";
        } else {
            strStatus = @"open_app";
        }
        
        [Common showNetworkActivityIndicator];
        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
        NSMutableDictionary *request_param = [@{
                                                @"access_token":[UserDefault user].token,
                                                @"latitude":@(userLocation.latitude),
                                                @"longitude":@(userLocation.longitude),
                                                @"status":strStatus,
                                                @"created_date":[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000],
                                                } mutableCopy];
        //NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_UPDATE_LOCATION));
        [manager PUT:URL_SERVER_API(API_UPDATE_LOCATION) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [Common hideNetworkActivityIndicator];
            if ([Common validateRespone:responseObject]) {
                //NSLog(@"Update user location thanh cong...");
                [UserDefault user].strLat = [NSString stringWithFormat:@"%g", userLocation.latitude];
                [UserDefault user].strLong = [NSString stringWithFormat:@"%g", userLocation.longitude];
                [[UserDefault user] update];
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


#pragma mark - TABLE DELEGATE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tblPosted) {
        return [_arrDummyContents count];
    }
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _tblUsers) {
        usersCell *cell = [tableView dequeueReusableCellWithIdentifier:@"usersCellId" forIndexPath:indexPath];
        cell.lblName.text = @"Ben Murray";
        cell.lblDistanceKm.text = @"3 km away";
        cell.imgAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
        
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
    
    if(tableView == _tblPosted) {
        postsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postedCellId" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([postsCell class]) owner:nil options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [Common circleImageView:cell.imgAvatar];
        
        float height_content_post = [Common getHeightOfText:WIDTH_CONTENT_AREA_POST_LIST andText:[_arrDummyContents objectAtIndex:indexPath.row] andFont:FONT_TEXT_CONTENT_POST];
        
        //Set frame for text content
        int xTextConten = 5;
        if ([Common checkIphoneVersion:@"6"]) {
            xTextConten = 20;
        }
        if ([Common checkIphoneVersion:@"6P"]) {
            xTextConten = 30;
        }
        cell.lblContent.frame = CGRectMake(xTextConten, HEIGHT_NAME_AREA_POST_LIST, WIDTH_CONTENT_AREA_POST_LIST, height_content_post);
        cell.lblContent.text = [_arrDummyContents objectAtIndex:indexPath.row];
        
        if (indexPath.row == selectedIndexPath) {
            cell.btShowAllComments.hidden = YES;
        } else {
            cell.btShowAllComments.hidden = NO;
        }
        cell.btShowAllComments.tag = indexPath.row;
        [cell.btShowAllComments addTarget:self action:@selector(actionShowAll:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btAddComment addTarget:self action:@selector(actionAddComment:) forControlEvents:UIControlEventTouchUpInside];
        
        //Set frame of ViewLikeComments
        int xViewLikeCm = 0;
        if ([Common checkIphoneVersion:@"6"]) {
            xViewLikeCm = 7;
        }
        if ([Common checkIphoneVersion:@"6P"]) {
            xViewLikeCm = 15;
        }
        CGRect frameT;
        frameT.origin.x = xViewLikeCm;
        frameT.origin.y = HEIGHT_NAME_AREA_POST_LIST + height_content_post;
        frameT.size.height = HEIGHT_LIKE_COMMENT_AREA_POST_LIST;
        frameT.size.width = WIDTH_LIKE_COMMENT_AREA_POST_LIST;
        cell.viewLikeCommentsArea.frame = frameT;
        
        //Set frame of viewComments
        int xViewCm = 5;
        if ([Common checkIphoneVersion:@"6"]) {
            xViewCm = 7;
        }
        if ([Common checkIphoneVersion:@"6P"]) {
            xViewCm = 10;
        }
        frameT = cell.viewCommentsArea.frame;
        frameT.origin.x = xViewCm;
        frameT.origin.y = HEIGHT_LIKE_DISLIKE_AREA_POST_LIST;
        frameT.size.height = HEIGHT_COMMENT_AREA_POST_LIST;
        frameT.size.width = WIDTH_COMMENT_AREA_POST_LIST;
        
        //Remove subview comment
        NSArray *subViewsComment = [cell.viewCommentsArea subviews];
        for (UIView *v in subViewsComment) {
            if (![[v class] isSubclassOfClass:[UIButton class]]) {
                [v removeFromSuperview];
            }
        }
        
        BOOL isLoadAllCm = false;
        if (selectedIndexPath == indexPath.row) {
            isLoadAllCm = true;
        }
        
        UIView *viewCm = [self returnCommentsView:_arrDummyComments andLoadAll:isLoadAllCm andFrom:@"post"];
        [cell.viewCommentsArea addSubview:viewCm];
        
        cell.viewCommentsArea.frame = frameT;
        return cell;
    }
    
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float heightOfRow = 100;
    
    if (tableView == _tblPosted) {
        
        heightOfRow = HEIGHT_NAME_AREA_POST_LIST;
        heightOfRow += HEIGHT_LIKE_COMMENT_AREA_POST_LIST;
        heightOfRow += [Common getHeightOfText:WIDTH_CONTENT_AREA_POST_LIST andText:[_arrDummyContents objectAtIndex:indexPath.row] andFont:FONT_TEXT_CONTENT_POST];
        heightOfRow += 10;
        
        if (indexPath.row == selectedIndexPath) {
            heightOfRow += [self returnCommentsView:_arrDummyComments andLoadAll:true andFrom:@"post"].frame.size.height;
            heightOfRow -= HEIGHT_COMMENT_AREA_POST_LIST;
        }
    }
    
    return heightOfRow;
}

#pragma mark - UITEXTFIELD DELEGATE
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.autocapitalizationType = UITextAutocorrectionTypeNo;
    [_scrDashboard setContentOffset:CGPointMake(0, 190) animated:YES];
    [self showComposeView:_viewCompose];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [_scrDashboard setContentOffset:CGPointMake(0, 0) animated:YES];
    
    if(textField == _txtCompose) {
        [self hideComposeView:_viewCompose];
    }
    return YES;
}

#pragma mark - COMPOSE POST
- (void)keyboardWillToggle:(NSNotification *)notification {
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
    
    NSLog(@"size change: %f", sizeChange);
    heightKeyboard = sizeChange;
    
    if (abs(sizeChange) > 40) {
        if (sizeChange < 0) {
            [_scrDashboard setContentOffset:CGPointMake(0, abs(sizeChange) - 20) animated:YES];
        } else {
            [_scrDashboard setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
    
    
    CGRect newContainerFrame = [[self container] frame];
    newContainerFrame.size.height += sizeChange;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [[self container] setFrame:newContainerFrame];
                         if (_viewComposePhoto != nil) {
                             CGRect framePhotoV = _viewComposePhoto.frame;
                             framePhotoV.origin.y = _container.frame.size.height - _viewComposePhoto.frame.size.height - _composeBarView.frame.size.height;
                             _viewComposePhoto.frame = framePhotoV;
                         }
                     }
                     completion:NULL];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    [composeBarView resignFirstResponder];
    _container.hidden = YES;
    _viewComposePhoto = nil;
    NSArray *viewsToRemove = [_scrCompose subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    _viewComposePhoto.hidden = YES;
    if([delegate respondsToSelector:@selector(homeHideKeyBoard)])
    {
        [delegate homeHideKeyBoard];
    }
    
    [_arr_data_media_temp removeAllObjects];
    _arr_data_media_temp = [_arr_data_media mutableCopy];
    [_arr_data_media removeAllObjects];
    
    [self callWSPostCompose];
}

- (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView {
    [self showActionSheetOptionComposeImage];
    
    /*
    if (!(_viewCameraChoosing != nil && _viewCameraChoosing.hidden == NO)) {
        [self bringTouchViewToFront];
    }
     */
}

- (void) actionTapDeleteImgPost:(id) sender {
    UIButton *bt = (UIButton *)sender;
    
    //Remove data in array
    if ([[[_arr_data_media objectAtIndex:(bt.tag - 1)] class] isSubclassOfClass:[NSURL class]]) {
        [self deleteFileTemp:(NSURL *)[_arr_data_media objectAtIndex:(bt.tag - 1)]];
    }
    [_arr_data_media replaceObjectAtIndex:(bt.tag - 1) withObject:[NSNull null]];
    
    for (id subview in _scrCompose.subviews) {
        if ([subview isMemberOfClass:[UIView class]]) {
            UIView *viewS = (UIView *)subview;
            if (viewS.tag == bt.tag) {
                [viewS removeFromSuperview];
                if ([_scrCompose.subviews count] == 2 || [_scrCompose.subviews count] == 0) {
                    [_scrCompose setContentSize:CGSizeMake([Common widthScreen], _scrCompose.frame.size.height)];
                    [_viewComposePhoto setHidden:YES];
                    _viewComposePhoto = nil;
                    if (_composeBarView.textView.text.length == 0) {
                        _composeBarView.button.enabled = NO;
                    }
                } else {
                    [self fixPositionAfterDeleteImgPost];
                }
            }
        }
    }
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
   willChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
              duration:(NSTimeInterval)duration
        animationCurve:(UIViewAnimationCurve)animationCurve
{
    float changeHeight = endFrame.size.height - startFrame.size.height;
    CGRect frameT = _viewComposePhoto.frame;
    frameT.origin.y -= changeHeight;
    _viewComposePhoto.frame = frameT;
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
        [_container addSubview:_btHideCompose];
    }
    
    return _container;
}


- (PHFComposeBarView *) composeBarView {
    if (!_composeBarView) {
        NSLog(@"%f  %f", kInitialViewFrame.size.height, [Common heightScreen]);
        CGRect frame = CGRectMake(0.0f,
                                  [Common heightScreen] - PHFComposeBarViewInitialHeight,
                                  [Common widthScreen],
                                  PHFComposeBarViewInitialHeight);
        _composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
        [_composeBarView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
        _composeBarView.buttonTintColor = COLOR_BUTTON_POST_SEND;
        [_composeBarView.textView setFont:FONT_TEXT_POST];
        [_composeBarView setMaxCharCount:2000];
        [_composeBarView setMaxLinesCount:63];
        [_composeBarView setButtonTitle:@"Post"];
        [_composeBarView setPlaceholder:@"Type something..."];
        [_composeBarView setUtilityButtonImage:[UIImage imageNamed:@"Camera"]];
        
        /* Change frame of button */
        [Common changeWidth:_composeBarView.utilityButton andWidth:40];
        [Common changeHeight:_composeBarView.utilityButton andHeight:30];
        [Common changeY:_composeBarView.utilityButton andY:8];
        [Common changeX:_composeBarView.utilityButton andX:-2];
        
        [_composeBarView.button setTitleColor:COLOR_BUTTON_POST_SEND forState:UIControlStateDisabled];
        _composeBarView.maxCharCount = 0;
        _composeBarView.button.enabled = YES;
        [_composeBarView setDelegate:self];
    }
    
    return _composeBarView;
}

- (void) initComposeImage {
    float yT = [Common heightScreen] + heightKeyboard - 80.f - PHFComposeBarViewInitialHeight;
    
    _viewComposePhoto = [[UIView alloc] initWithFrame:CGRectMake(0, yT, [Common widthScreen], 80)];
    _viewComposePhoto.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.5];
    
    _scrCompose = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [Common widthScreen], 80)];
    [_scrCompose setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    _scrCompose.backgroundColor = [UIColor clearColor];
    
    [_viewComposePhoto addSubview:_scrCompose];
    [_container addSubview:_viewComposePhoto];
}

- (void) fixPositionAfterDeleteImgPost {
    float xPosition = 3;
    for (id subview in _scrCompose.subviews) {
        if ([subview isMemberOfClass:[UIView class]]) {
            UIView *viewS = (UIView *)subview;
            CGRect frameT = viewS.frame;
            frameT.origin.x = xPosition;
            [UIView animateWithDuration:1.0 animations:^{
                viewS.frame = frameT;
            }];
            xPosition += (WIDTH_A_IMAGE_VIDEO_POST + 3);
        }
    }
    xPosition += (WIDTH_A_IMAGE_VIDEO_POST + 6);
    if (xPosition > _scrCompose.frame.size.width) {
        [_scrCompose setContentSize:CGSizeMake(xPosition, _scrCompose.frame.size.height)];
        _scrCompose.scrollEnabled = YES;
    } else {
        [_scrCompose setContentSize:CGSizeMake([Common widthScreen], _scrCompose.frame.size.height)];
        _scrCompose.scrollEnabled = NO;
    }
}

- (void) addImagePost:(UIImage *)imgP {
    _viewComposePhoto.hidden = NO;
    float xPosition = 0;
    int tagIndex = 1;
    for (id subview in _scrCompose.subviews) {
        if ([subview isMemberOfClass:[UIView class]]) {
            UIView *viewS = (UIView *)subview;
            xPosition += (viewS.frame.size.width + 3);
            tagIndex++;
        }
    }
    
    
    UIView *viewAPost = [[UIView alloc] initWithFrame:CGRectMake(xPosition + 3, 3, WIDTH_A_IMAGE_VIDEO_POST, WIDTH_A_IMAGE_VIDEO_POST)];
    UIImageView *imagePost = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_A_IMAGE_VIDEO_POST, WIDTH_A_IMAGE_VIDEO_POST)];
    imagePost.image = imgP;
    UIButton *btPost = [[UIButton alloc] initWithFrame:CGRectMake(40, 4, 30, 30)];
    [btPost setBackgroundImage:[UIImage imageNamed:@"bt_img_cancel"] forState:UIControlStateNormal];
    [btPost addTarget:self action:@selector(actionTapDeleteImgPost:) forControlEvents:UIControlEventTouchUpInside];
    
    btPost.tag = tagIndex;
    viewAPost.tag = tagIndex;
    
    [viewAPost addSubview:imagePost];
    [viewAPost addSubview:btPost];
    [_scrCompose addSubview:viewAPost];
    _composeBarView.button.enabled = YES;
    
    xPosition += (WIDTH_A_IMAGE_VIDEO_POST + 6);
    if (xPosition > _scrCompose.frame.size.width) {
        [_scrCompose setContentSize:CGSizeMake(xPosition, _scrCompose.frame.size.height)];
        _scrCompose.scrollEnabled = YES;
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
        //cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
    } else {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // Displays a control that allows the user to choose picture or
        // movie capture, if both are available:
        cameraUI.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypeCamera];
        
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        cameraUI.allowsEditing = NO;
        cameraUI.videoQuality = UIImagePickerControllerQualityTypeHigh;
        cameraUI.videoMaximumDuration = 10;
    }
    
    
    cameraUI.delegate = delegate;
    
    //[controller presentModalViewController: cameraUI animated: YES];
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    _viewComposePhoto.hidden = YES;
    _container.hidden = YES;
    [picker dismissViewControllerAnimated:YES completion:^(void) {
        int64_t delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_container setFrame:CGRectMake(0, 0, [Common widthScreen], [Common heightScreen])];
            _container.hidden = NO;
            [_composeBarView.textView becomeFirstResponder];
            _viewComposePhoto.hidden = NO;
        });
        
    }];

}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    imageToSave = nil;
    NSURL *videoURL = nil;
    
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
        [_arr_data_media addObject:imageToSave];
        
    }
    
    // Handle a movie capture
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
            == kCFCompareEqualTo) {
            videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            imageToSave = [Common thumbnailImageForVideo:videoURL atTime:1];
        }
    _viewComposePhoto.hidden = YES;
    _container.hidden = YES;
    [picker dismissViewControllerAnimated:YES completion:^(void) {
        int64_t delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_container setFrame:CGRectMake(0, 0, [Common widthScreen], [Common heightScreen])];
            _container.hidden = NO;
            [_composeBarView.textView becomeFirstResponder];
            if (!_viewComposePhoto) {
                [self initComposeImage];
            }
            [self addImagePost:imageToSave];
            if (videoURL != nil) {
                AVAsset *video = [AVAsset assetWithURL:videoURL];
                AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:video presetName:AVAssetExportPresetMediumQuality];
                exportSession.shouldOptimizeForNetworkUse = YES;
                exportSession.outputFileType = AVFileTypeMPEG4;
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
                basePath = [basePath stringByAppendingPathComponent:@"videos"];
                if (![[NSFileManager defaultManager] fileExistsAtPath:basePath])
                    [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
                
                NSURL *compressedVideoUrl=nil;
                compressedVideoUrl = [NSURL fileURLWithPath:basePath];
                long CurrentTime = [[NSDate date] timeIntervalSince1970];
                NSString *strImageName = [NSString stringWithFormat:@"%ld",CurrentTime];
                compressedVideoUrl=[compressedVideoUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",strImageName]];
                
                exportSession.outputURL = compressedVideoUrl;
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    switch ([exportSession status])
                    {
                        case AVAssetExportSessionStatusCompleted:{
                            NSLog(@"MP4 Successful!");
                            [_arr_data_media addObject:compressedVideoUrl];
                        }
                            break;
                        case AVAssetExportSessionStatusFailed:
                        {
                            NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                        }
                            break;
                        case AVAssetExportSessionStatusCancelled:
                            NSLog(@"Export canceled");
                            break;
                        default:
                            break;
                    }
                    
                }];
                
            }
        });
        
    }];
    
}

#pragma mark CIRCLE VIEW
- (void) circleViewConfig {
    _circular_slider.minimumTrackTintColor = [UIColor clearColor];
    _circular_slider.maximumTrackTintColor = [UIColor clearColor];
    _circular_slider.thumbTintColor = [UIColor whiteColor];
    
    [_circular_slider addTarget:self action:@selector(updateprogress:) forControlEvents:UIControlEventValueChanged];
    [_circular_slider addTarget:self action:@selector(touchupinside:) forControlEvents:UIControlEventTouchUpInside];
    [_circular_slider addTarget:self action:@selector(touchupinside:) forControlEvents:UIControlEventTouchUpOutside];
    
    _circular_slider.minimumValue = minximumCircleSlider;
    _circular_slider.maximumValue = maximumCircleSlider;
    _circular_slider.continuous = YES;
}
- (void) updateprogress:(UISlider *)sender {
    if ([Common validateLocationCoordinate2DIsValid:userLocation]) {
        radiusUpdate = (round((sender.value * unitRadiusCircleSlider / 1000.0f)*100)) / 100.0;
        NSLog(@"radiusUpdate: %f", radiusUpdate);
        _lblRadiusMap.text = [NSString stringWithFormat:@"%dkm", (int)radiusUpdate];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation, radiusUpdate * 1000.0f, radiusUpdate * 1000.0f);
        [_mapV setRegion:[_mapV regionThatFits:region] animated:YES];
    }
}

- (void) touchupinside:(id) sender {
    if (radiusUpdate > 100) {
        radiusUpdate = 100;
    }
    [self callWSGetUserPostList];
}



#pragma mark LOCATION DELEGATE
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"DidUpdate Location HOME");
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    NSLog(@"%d", abs(howRecent));
    if (abs(howRecent) < 15.0) {
        //NSLog(@"Location Update: %@ %f", locations, location.horizontalAccuracy);
        userLocation.latitude = location.coordinate.latitude;
        userLocation.longitude = location.coordinate.longitude;
        [UserDefault user].strLat = [NSString stringWithFormat:@"%g", location.coordinate.latitude];
        [UserDefault user].strLong = [NSString stringWithFormat:@"%g", location.coordinate.longitude];
        [[UserDefault user] update];
        [self addPinViewToMap:userLocation andRegion:CGSizeMake(radiusUpdate * 1000.0f, radiusUpdate * 1000.0f)];
        _lblRadiusMap.text = [NSString stringWithFormat:@"%dkm", (int)(radiusUpdate)];
        if (CLLocationCoordinate2DIsValid(userLocation) && [[UserDefault user].token length] > 0) {
            [self callWSGetUserPostList];
        }
    }
    //[locationManager stopUpdatingLocation];
}

#pragma mark MAP DELEGATE
- (void) locationCurrentInit {
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
}

-(void)removeAllAnnotations
{
    id userAnnotation = _mapV.userLocation;
    
    NSMutableArray *annotations = [NSMutableArray arrayWithArray:_mapV.annotations];
    [annotations removeObject:userAnnotation];
    
    [_mapV removeAnnotations:annotations];
}

-(void) addPinViewToMap:(CLLocationCoordinate2D) location andRegion:(CGSize) regionSize {
    //Remove all before add pin
    [self removeAllAnnotations];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, regionSize.width, regionSize.height);
    [_mapV setRegion:[_mapV regionThatFits:region] animated:YES];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = location;
    [_mapV addAnnotation:point];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString* AnnotationIdentifier = @"Annotation";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (!pinView) {
        MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 10, 35, 35)];
        imageV.image = [UIImage imageNamed:@"pointer_map.png"];
        if (annotation == mapView.userLocation){
            customPinView.image = [UIImage imageNamed:@""];
            [customPinView addSubview:imageV];
        }
        else{
            [customPinView addSubview:imageV];
            customPinView.image = [UIImage imageNamed:@""];
            //customPinView.pinColor = MKPinAnnotationColorRed;
        }
        customPinView.animatesDrop = NO;
        customPinView.canShowCallout = YES;
        return customPinView;
        
    } else {
        pinView.centerOffset = CGPointMake(0, -35 / 2);
        pinView.annotation = annotation;
    }
    
    return pinView;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case 1:
            switch (buttonIndex) {
                case 0:
                    [self actionTakePhotoVideo:nil];
                    break;
                case 1:
                    [self actionChooseExisting:nil];
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}



@end
