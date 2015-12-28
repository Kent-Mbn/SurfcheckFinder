//
//  PostListVC.m
//  Skope
//
//  Created by Huynh Phong Chau on 3/4/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "PostListVC.h"
#import "PageContainVC.h"

CGRect const kInitialViewFramePostInput = { 0.0f, 0.0f, 320.0f, 480.0f };
#define COUNT_START_COMMENTS 2

@interface PostListVC ()

@end

@implementation PostListVC

@synthesize delegate;
@synthesize dicPostList;
@synthesize arrDummyContents = _arrDummyContents;
@synthesize arrDummyComments = _arrDummyComments;
@synthesize composeBarView = _composeBarView;
@synthesize container = _container;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isReload = false;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillTogglePost:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillTogglePost:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _arrDummyContents = [[NSMutableArray alloc] initWithArray:[Common arrContentPosts]];
    _arrDummyComments = [[NSMutableArray alloc] initWithArray:[Common arrComments]];
    _arrPlData = [[[NSMutableArray alloc] init] mutableCopy];
    selectedIndexPath = -1;
    addCommentAtIndex = -1;
    pageIndex = 1;
    totalPage = 0;
    //_tblView.layer.opaque = YES;
    
    _container = [self container];
    [_container addSubview:[self composeBarView]];
    [self.view addSubview:_container];
    _container.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void) viewDidAppear:(BOOL)animated {
    if ((self.regionMap > 0 && self.regionMap != regionMapTemp) || self.isReload) {
        regionMapTemp = self.regionMap;
        self.regionMap = 0;
        if (_arrPlData) {
            pageIndex = 1;
            totalPage = 0;
        }
        [_tblView setContentOffset:CGPointZero animated:YES];
        [self callWSGetPostList:pageIndex andLimit:LIMIT_LIST_POST];
    } else {
        [self callWSGetPostList:1 andLimit:(pageIndex * LIMIT_LIST_POST)];
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

#pragma mark - FUNCTIONS
- (UIView *) returnCommentsView:(NSMutableArray *) arrComments andLoadAll:(BOOL) isAll andFrom:(NSString *) strFrom{
    //int height_name_cm = 55;
    
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
            widthCm -= 20;
        } else if ([Common checkIphoneVersion:@"6P"]) {
            widthCm -= 10;
        } else {
            widthCm -= 10;
        }
    }
    
    
    UIView *viewT = [[UIView alloc] initWithFrame:CGRectMake(3, 10, widthCm, 0)];
    float y = 0.0;
    int length = 1;
    if(isAll) {
        length = [arrComments count];
    } else {
        if ([arrComments count] <= COUNT_START_COMMENTS) {
            length = [arrComments count];
        }
    }
    
    for (int i = 0; i < length; i++) {
        NSDictionary *objCm = [arrComments objectAtIndex:i];
        NSString *strT = objCm[@"content"];
        NSString *strUrlAvatar = objCm[@"user"][@"avatar"];
        NSString *strName = objCm[@"user"][@"name"];
        NSDate *created_date = [NSDate dateWithTimeIntervalSince1970:[objCm[@"created_at"] doubleValue]];
        NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
        [dateformate setDateFormat:@"dd/MM/yyyy"];
        NSString *strDate = [dateformate stringFromDate:created_date];
        
        
        float heightT = [Common getHeightOfText:widthCm andText:strT andFont:FONT_TEXT_COMMENTS];
        
        /*
        //Create view for contain name, avatar, date and comment.
        UIView *viewNameAvatarCm = [[UIView alloc] initWithFrame:CGRectMake(0, y, widthCm, heightT + height_name_cm + 15)];
        viewNameAvatarCm.backgroundColor = bgColor;
        
        
        //Create avatar view
        UIImageView *cmAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [cmAvatar sd_setImageWithURL:[NSURL URLWithString:strUrlAvatar] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            cmAvatar.image = [Common imageWithRoundedCornersSize:(40.0) usingImage:image];
        }];
        
        //Create name label
        UILabel *cmLblName = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 200, 25)];
        cmLblName.font = FONT_TEXT_COMMENTS_NAME;
        cmLblName.textColor = COLOR_GREEN_LIKE;
        cmLblName.text = strName;
        
        //Create date label
        UILabel *cmLblDate = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 200, 20)];
        cmLblDate.font = FONT_TEXT_COMMENTS_DATE;
        cmLblDate.textColor = [UIColor lightGrayColor];
        cmLblDate.text = strDate;
        */
        
        //Create content of comment
        TTTAttributedLabel *lbl = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, y, widthCm, heightT + 10)];
        lbl.layer.borderColor = (__bridge CGColorRef)(bgColor);
        lbl.layer.borderWidth = 1.0;
        lbl.layer.cornerRadius = 2.0;
        lbl.layer.masksToBounds = YES;
        lbl.backgroundColor = bgColor;
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

- (void)actionShowAll:(id) sender {
    UIButton *bt = (UIButton *) sender;
    if ([[_arrPlData objectAtIndex:bt.tag][@"cm_expand"] isEqualToString:@"false"]) {
        [_arrPlData objectAtIndex:bt.tag][@"cm_expand"] = @"true";
    } else {
        [_arrPlData objectAtIndex:bt.tag][@"cm_expand"] = @"false";
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:bt.tag inSection:0];
    [_tblView reloadRowsAtIndexPaths:@[indexPath]
                      withRowAnimation:UITableViewRowAnimationFade];
}

- (void)actionAddComment:(id) sender {
    UIButton *bt = (UIButton *) sender;
    NSLog(@"bt tag: %d", bt.tag);
    addCommentAtIndex = bt.tag;
    _composeBarView.textView.text = @"";
    _container.hidden = NO;
    [_composeBarView.textView becomeFirstResponder];
    [_composeBarView setUtilityButtonImage:nil];
    if([delegate respondsToSelector:@selector(postListShowKeyboard)])
    {
        [delegate postListShowKeyboard];
    }
}

- (void) actionLikePost:(id)sender {
    UIButton *bt = (UIButton *) sender;
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:bt.tag inSection:0];
    
    NSString *str_voted_type = [_arrPlData objectAtIndex:indexP.row][@"voted_type"];
    int number_like = [[_arrPlData objectAtIndex:indexP.row][@"like"][@"total"] integerValue];
    int number_dislike = [[_arrPlData objectAtIndex:indexP.row][@"dislike"][@"total"] integerValue];
    if ([str_voted_type isEqualToString:@"dislike"] || str_voted_type.length == 0) {
        if (number_dislike > 0) {
            number_dislike--;
        }
        number_like++;
        
        [_arrPlData objectAtIndex:indexP.row][@"like"][@"total"] = @(number_like);
        [_arrPlData objectAtIndex:indexP.row][@"dislike"][@"total"] = @(number_dislike);
        [_arrPlData objectAtIndex:indexP.row][@"voted_type"] = @"like";
        
        NSIndexPath *indexPNew = [NSIndexPath indexPathForRow:indexP.row inSection:0];
        [_tblView reloadRowsAtIndexPaths:@[indexPNew]
                        withRowAnimation:UITableViewRowAnimationFade];
        
        
        [self callWSPfLikeDislikePost:[_arrPlData objectAtIndex:bt.tag][@"id"] andLikeDislike:@"like" andIndexPath:indexP];
    }
}

- (void) actionDislikePost:(id)sender {
    UIButton *bt = (UIButton *) sender;
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:bt.tag inSection:0];
    
    NSString *str_voted_type = [_arrPlData objectAtIndex:indexP.row][@"voted_type"];
    int number_like = [[_arrPlData objectAtIndex:indexP.row][@"like"][@"total"] integerValue];
    int number_dislike = [[_arrPlData objectAtIndex:indexP.row][@"dislike"][@"total"] integerValue];
    if ([str_voted_type isEqualToString:@"like"]  || str_voted_type.length == 0) {
        number_dislike++;
        if (number_like > 0) {
            number_like--;
        }
        
        [_arrPlData objectAtIndex:indexP.row][@"like"][@"total"] = @(number_like);
        [_arrPlData objectAtIndex:indexP.row][@"dislike"][@"total"] = @(number_dislike);
        [_arrPlData objectAtIndex:indexP.row][@"voted_type"] = @"dislike";
        
        NSIndexPath *indexPNew = [NSIndexPath indexPathForRow:indexP.row inSection:0];
        [_tblView reloadRowsAtIndexPaths:@[indexPNew]
                        withRowAnimation:UITableViewRowAnimationFade];
        
        [self callWSPfLikeDislikePost:[_arrPlData objectAtIndex:bt.tag][@"id"] andLikeDislike:@"dislike" andIndexPath:indexP];
    }
}

- (void) showImage:(id) sender {
    
    ButtonShowImageSlide *bt = (ButtonShowImageSlide *)sender;
    NSLog(@"Dang chon cell: %d and %d", bt.indexPathCell.row, (int)bt.indexImageSelected);
    
    NSArray *arrMedia = [_arrPlData objectAtIndex:bt.indexPathCell.row][@"media"];
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

#pragma mark - CALL WS
- (void) callWSGetPostList:(int) para_page_index andLimit:(int) para_page_limit {
    //[Common showLoadingViewGlobal:nil];
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"access_token":[UserDefault user].token,
                                            @"latitude":[UserDefault user].strLat,
                                            @"longitude":[UserDefault user].strLong,
                                            @"distance":@(regionMapTemp),
                                            @"page":@(para_page_index),
                                            @"limit":@(para_page_limit),
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_LIST_POST));
    [manager GET:URL_SERVER_API(API_LIST_POST) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
        self.isReload = false;
        NSLog(@"respone post list: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                if (success) {
                    if (object[@"data"][@"items"] != nil) {
                        if (object[@"data"][@"total"] != nil) {
                            totalPage = [object[@"data"][@"total"] intValue];
                        }
                        if (para_page_index == 1) {
                            [_arrPlData removeAllObjects];
                        }
                        for (int i = 0; i < [object[@"data"][@"items"] count]; i++) {
                            object[@"data"][@"items"][i][@"cm_expand"] = @"false";
                            
                            //TODO: remove
                            /*
                            object[@"data"][@"items"][i][@"content"] = @"jkjlksd lskdjflksj lskdjlskjd sldkjlsdj lksjd lsldjlskjdlskjdlskjdlsjd lksjdlksjdlf;alsdjf lskdjlskdjksjd lskdjls;alskdj slkjdlksjdlkjd hjdshfkjh ksjhdkjfhks dkjfhksjdhf ksjhdkfjshd kfjhskdjfhs kjdhksjhd kfjshdkjfhskjd kfjshdkjhkjh skdjhkfjhs kdjhskjdh fksjdh fksjdhskjdhks";
                            
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
                            
                            //calculate string date
                            NSDate *created_date = [NSDate dateWithTimeIntervalSince1970:[object[@"data"][@"items"][i][@"created_at"] doubleValue]];
                            NSString *str_created_date = [created_date timeAgo];
                            if ([str_created_date rangeOfString:@"Last"].location == NSNotFound) {
                                object[@"data"][@"items"][i][@"str_created_at"] = str_created_date;
                            } else {
                                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                                [dateformate setDateFormat:@"dd/MM/yyyy"];
                                NSString *date = [dateformate stringFromDate:created_date];
                                object[@"data"][@"items"][i][@"str_created_at"] = date;
                            }
                            
                            //calculate km away
                            CLLocationCoordinate2D userLocation = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@",[UserDefault user].strLat, [UserDefault user].strLong]];
                            CLLocationCoordinate2D postLocation = [Common get2DCoordFromString:[NSString stringWithFormat:@"%@,%@",object[@"data"][@"items"][i][@"location"][@"latitude"], object[@"data"][@"items"][i][@"location"][@"longitude"]]];
                            float kmAway = [Common kilometersfromPlace:userLocation andToPlace:postLocation];
                            if (kmAway > 1) {
                                object[@"data"][@"items"][i][@"km_away"] = [NSString stringWithFormat:@"Posted %.0f kms away", kmAway];
                            } else {
                                object[@"data"][@"items"][i][@"km_away"] = [NSString stringWithFormat:@"Posted %.0f km away", kmAway];
                            }
                            
                            //calculate height of text content
                            int widthConten = 270;
                            if ([Common checkIphoneVersion:@"6"]) {
                                widthConten = 320;
                            }
                            if ([Common checkIphoneVersion:@"6P"]) {
                                widthConten = 360;
                            }
                            float height_content_post = [Common getHeightOfText:widthConten andText:object[@"data"][@"items"][i][@"content"] andFont:FONT_TEXT_CONTENT_POST];
                            object[@"data"][@"items"][i][@"height_content"] = @(height_content_post);
                            
                            [_arrPlData addObject:object[@"data"][@"items"][i]];
                        }
                        if ([_arrPlData count] > 0) {
                            [_tblView reloadData];
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
        self.isReload = false;
        [Common hideLoadingViewGlobal];
        [Common hideNetworkActivityIndicator];
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
            [[_arrPlData objectAtIndex:indexPath.row][@"comment"][@"items"] insertObject:responseObject[@"data"][@"comment"] atIndex:0];
            NSIndexPath *indexPNew = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            int totalCm = [[_arrPlData objectAtIndex:indexPath.row][@"comment"][@"total"] intValue];
            totalCm++;
            [_arrPlData objectAtIndex:indexPath.row][@"comment"][@"total"] = @(totalCm);
            [_tblView reloadRowsAtIndexPaths:@[indexPNew]
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
                /*
                [_arrPlData objectAtIndex:indexPath.row][@"like"][@"total"] = object[@"data"][@"post"][@"like"][@"total"];
                [_arrPlData objectAtIndex:indexPath.row][@"dislike"][@"total"] = object[@"data"][@"post"][@"dislike"][@"total"];
                [_arrPlData objectAtIndex:indexPath.row][@"voted_type"] = strLike;
                NSIndexPath *indexPNew = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                [_tblView reloadRowsAtIndexPaths:@[indexPNew]
                                       withRowAnimation:UITableViewRowAnimationFade];
                 */
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


#pragma mark - COMPOSE POST
- (void)keyboardWillTogglePost:(NSNotification *)notification {
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
    if([delegate respondsToSelector:@selector(postListHideKeyboard)])
    {
        [delegate postListHideKeyboard];
    }
    
    [self callWSAddComment:[_arrPlData objectAtIndex:addCommentAtIndex][@"id"] andTextCm:composeBarView.textView.text andIndexPath:[NSIndexPath indexPathForRow:addCommentAtIndex inSection:0]];
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
        NSLog(@"%f  %f", kInitialViewFramePostInput.size.height, [Common heightScreen]);
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


#pragma mark - TABLE DELEGATE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count_array = (int)[_arrPlData count];
    if (totalPage > count_array) {
        return count_array + 1;
    }
    return [_arrPlData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [_arrPlData count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postedLoadingCellId"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"postedLoadingCellId"];
        }
        UIActivityIndicatorView *indicatorV = (UIActivityIndicatorView *)[cell viewWithTag:12];
        [indicatorV startAnimating];
        
        int x_indicator = 140;
        if ([Common checkIphoneVersion:@"6"]) {
            x_indicator = 170;
        } else if([Common checkIphoneVersion:@"6P"]) {
            x_indicator = 180;
        }
        [Common changeX:indicatorV andX:x_indicator];
        
        return cell;
    } else {
        if ([_arrPlData count] > 0) {
            static NSString *CellIdentifier = @"postedCellId";
            postsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[postsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //cell.layer.opaque = YES;
            //[Common circleImageView:cell.imgAvatar];
            
            NSDictionary *obj = [_arrPlData objectAtIndex:indexPath.row];
            
            /*** NAME AND AVATAR AND DATE CREATED ***/
            [Common circleImageView:cell.imgAvatar];
            [cell.imgAvatar sd_setImageWithURL:[NSURL URLWithString:obj[@"user"][@"avatar"]]];
            //        [cell.imgAvatar sd_setImageWithURL:[NSURL URLWithString:obj[@"user"][@"avatar"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //            cell.imgAvatar.image = [Common imageWithRoundedCornersSize:(90.0) usingImage:image];
            //        }];
            cell.lblName.text = obj[@"user"][@"name"];
            if ([Common checkIphoneVersion:@"6"]) {
                [Common changeX:cell.lblTimeAgo andX:218];
            } else if([Common checkIphoneVersion:@"6P"]) {
                [Common changeX:cell.lblTimeAgo andX:258];
            } else {
                [Common changeX:cell.lblTimeAgo andX:165];
            }
            cell.lblTimeAgo.text = obj[@"str_created_at"];
            
            /*** POSTED AWAY KM ***/
            cell.lblPostedKm.text = obj[@"km_away"];
            
            
            /*** POST CONTENT ***/
            int widthConten = 270;
            if ([Common checkIphoneVersion:@"6"]) {
                widthConten = 320;
            }
            if ([Common checkIphoneVersion:@"6P"]) {
                widthConten = 360;
            }
            float height_content_post = [obj[@"height_content"] floatValue];
            [Common changeHeight:cell.lblContent andHeight:height_content_post];
            [Common changeY:cell.lblContent andY:HEIGHT_NAME_AREA_POST_LIST];
            [Common changeWidth:cell.lblContent andWidth:widthConten];
            cell.lblContent.text = obj[@"content"];
            
            
            /*** IMAGE SLIDE ***/
            int height_img_slide_area = 0;
            NSArray *arrayImgSlide = obj[@"media"];
            if ([arrayImgSlide count] > 0) {
                
                cell.viewBoundScrollImg.hidden = NO;
                cell.scrollView.hidden = NO;
                //Remove subview slide
                NSArray *subViewsSlide = [cell.scrollView subviews];
                for (UIView *v in subViewsSlide) {
                    [v removeFromSuperview];
                }
                
                
                height_img_slide_area = HEIGHT_SLIDE_IMAGE_POST_LIST;
                //Change Position Y
                [Common changeY:cell.viewBoundScrollImg andY:HEIGHT_NAME_AREA_POST_LIST + height_content_post + 15];
                [Common changeY:cell.scrollView andY:HEIGHT_NAME_AREA_POST_LIST + height_content_post + 15];
                
                float widthViewBoundImg = tableView.frame.size.width;
                CGRect frameT = cell.viewBoundScrollImg.frame;
                frameT.size.width = widthViewBoundImg;
                cell.viewBoundScrollImg.frame = frameT;
                
                frameT = cell.scrollView.frame;
                frameT.size.width = widthViewBoundImg - 30;
                cell.scrollView.frame = frameT;
                [Common changeX:cell.scrollView andX:10];
                cell.scrollView.clipsToBounds = NO;
                cell.scrollView.pagingEnabled = YES;
                cell.scrollView.showsHorizontalScrollIndicator = NO;
                
                CGFloat contentOffset = 0.0f;
                for (int i=0; i < [arrayImgSlide count]; i++) {
                    NSDictionary *objImg = [arrayImgSlide objectAtIndex:i];
                    CGRect imageViewFrame = CGRectMake(contentOffset, 0.0f, cell.scrollView.frame.size.width, cell.scrollView.frame.size.height);
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
                    btShowImage.indexPathCell = indexPath;
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
                    
                    
                    [cell.scrollView addSubview:imageView];
                    contentOffset += imageView.frame.size.width;
                    cell.scrollView.contentSize = CGSizeMake(contentOffset, cell.scrollView.frame.size.height);
                }
            }
            else {
                cell.viewBoundScrollImg.hidden = YES;
                cell.scrollView.hidden = YES;
            }
            
            /*** VIEW LIKE COMMENT ***/
            cell.btPLLike.tag = indexPath.row;
            cell.btPLDislike.tag = indexPath.row;
            
            if(true) {
                [Common changeY:cell.viewLikeCommentsArea andY:HEIGHT_NAME_AREA_POST_LIST + height_content_post + height_img_slide_area + 10];
            } else {
                [Common changeY:cell.viewLikeCommentsArea andY:HEIGHT_NAME_AREA_POST_LIST + height_content_post];
            }
            [Common changeHeight:cell.viewLikeCommentsArea andHeight:70];
            [Common changeWidth:cell.viewLikeCommentsArea andWidth:widthConten + 10];
            [cell.btPLLike addTarget:self action:@selector(actionLikePost:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btPLDislike addTarget:self action:@selector(actionDislikePost:) forControlEvents:UIControlEventTouchUpInside];
            cell.lblPLCountComment.text = [NSString stringWithFormat:@"Comments(%d)", [obj[@"comment"][@"total"] integerValue]];
            
            int numLike = [obj[@"like"][@"total"] intValue];
            int numDislike = [obj[@"dislike"][@"total"] intValue];
            cell.lblLikeNumber.text = [NSString stringWithFormat:@"%d", numLike];
            cell.lblDislikeNumber.text = [NSString stringWithFormat:@"%d", numDislike];
            [cell.btPLLike setTitleColor:COLOR_LIKE_ENABLE forState:UIControlStateNormal];
            [cell.btPLDislike setTitleColor:COLOR_DISLIKE_ENABLE forState:UIControlStateNormal];
            
            NSString *strVotedType = obj[@"voted_type"];
            
            if (strVotedType.length > 0) {
                cell.btPLLike.titleLabel.font = FONT_LIKE_DISLIKE_DISABLE;
                cell.btPLDislike.titleLabel.font = FONT_LIKE_DISLIKE_DISABLE;
                //            [cell.btPLLike setTitle:@"Likes" forState:UIControlStateNormal];
                //            [cell.btPLDislike setTitle:@"Dislikes" forState:UIControlStateNormal];
                //[cell.btPLLike setTitleColor:COLOR_LIKE_DISLIKE_DISABLE forState:UIControlStateNormal];
                //[cell.btPLDislike setTitleColor:COLOR_LIKE_DISLIKE_DISABLE forState:UIControlStateNormal];
                //cell.btPLLike.enabled = NO;
                //cell.btPLDislike.enabled = NO;
            } else {
                cell.btPLLike.titleLabel.font = FONT_LIKE_DISLIKE_DISABLE;
                cell.btPLDislike.titleLabel.font = FONT_LIKE_DISLIKE_DISABLE;
                //            [cell.btPLLike setTitle:@"Like" forState:UIControlStateNormal];
                //            [cell.btPLDislike setTitle:@"Dislike" forState:UIControlStateNormal];
                //[cell.btPLLike setTitleColor:COLOR_LIKE_DISLIKE_DISABLE forState:UIControlStateNormal];
                //[cell.btPLDislike setTitleColor:COLOR_LIKE_DISLIKE_DISABLE forState:UIControlStateNormal];
                //cell.btPLLike.enabled = YES;
                //cell.btPLDislike.enabled = YES;
            }
            
            if (numLike > 0 || numDislike > 0) {
                [Common changeWidth:cell.viewPLColorLike andWidth:(float)numLike/((float)numLike + (float)numDislike) * cell.viewPLColorLikeTotal.frame.size.width];
                cell.viewPLColorLike.backgroundColor = COLOR_LIKE_ENABLE;
                cell.viewPLColorLikeTotal.backgroundColor = [UIColor redColor];
                
                if (numLike > 0) {
                    cell.lblLikeNumber.textColor = COLOR_LIKE_ENABLE;
                    [cell.btPLLike setTitle:@"Likes" forState:UIControlStateNormal];
                } else {
                    cell.lblLikeNumber.textColor = COLOR_LIKE_DISLIKE_DISABLE;
                    [cell.btPLLike setTitle:@"Like" forState:UIControlStateNormal];
                }
                if (numDislike > 0) {
                    cell.lblDislikeNumber.textColor = COLOR_DISLIKE_ENABLE;
                    [cell.btPLDislike setTitle:@"Dislikes" forState:UIControlStateNormal];
                } else {
                    cell.lblDislikeNumber.textColor = COLOR_LIKE_DISLIKE_DISABLE;
                    [cell.btPLDislike setTitle:@"Dislike" forState:UIControlStateNormal];
                }
            } else {
                
                cell.viewPLColorLike.backgroundColor = COLOR_LIKE_DISLIKE_DISABLE;
                cell.viewPLColorLikeTotal.backgroundColor = COLOR_LIKE_DISLIKE_DISABLE;
                cell.lblLikeNumber.textColor = COLOR_LIKE_DISLIKE_DISABLE;
                cell.lblDislikeNumber.textColor = COLOR_LIKE_DISLIKE_DISABLE;
            }
            
            /*** VIEW COMMENT ***/
            [cell.btAddComment addTarget:self action:@selector(actionAddComment:) forControlEvents:UIControlEventTouchUpInside];
            cell.btAddComment.tag = indexPath.row;
            cell.lblPLCountComment.hidden = YES;
            
            int total_cm = [obj[@"comment"][@"total"] integerValue];
            if (total_cm > 0) {
                cell.viewCommentsArea.hidden = NO;
                [Common changeY:cell.viewCommentsArea andY:HEIGHT_NAME_AREA_POST_LIST+height_content_post+80+height_img_slide_area];
                [Common changeWidth:cell.viewCommentsArea andWidth:widthConten + 10];
                
                cell.btShowAllComments.tag = indexPath.row;
                [cell.btShowAllComments addTarget:self action:@selector(actionShowAll:) forControlEvents:UIControlEventTouchUpInside];
                
                /*** ADD COMMENT ***/
                //Remove subview comment
                NSArray *subViewsComment = [cell.viewCommentsArea subviews];
                for (UIView *v in subViewsComment) {
                    if (![[v class] isSubclassOfClass:[UIButton class]]) {
                        [v removeFromSuperview];
                    }
                }
                
                BOOL isLoadAllCm = false;
                [cell.btShowAllComments setTitle:@"Show all" forState:UIControlStateNormal];
                if ([obj[@"cm_expand"] isEqualToString:@"true"]) {
                    isLoadAllCm = true;
                    [cell.btShowAllComments setTitle:@"Hide" forState:UIControlStateNormal];
                }
                UIView *viewCm = [self returnCommentsView:obj[@"comment"][@"items"] andLoadAll:isLoadAllCm andFrom:@"profile"];
                [cell.viewCommentsArea addSubview:viewCm];
                if (total_cm > COUNT_START_COMMENTS) {
                    cell.btShowAllComments.hidden = NO;
                    cell.lblPLCountComment.hidden = NO;
                } else {
                    cell.btShowAllComments.hidden = YES;
                    cell.lblPLCountComment.hidden = YES;
                }
                if ([obj[@"cm_expand"] isEqualToString:@"true"]) {
                    cell.lblPLCountComment.hidden = YES;
                }
                [Common changeHeight:cell.viewCommentsArea andHeight:(viewCm.frame.size.height + 30)];
            } else {
                cell.viewCommentsArea.hidden = YES;
                cell.lblPLCountComment.hidden = YES;
            }
            
            /*** VIEW BG CELL ***/
            cell.viewBGCell.layer.opaque = YES;
            [Common changeHeight:cell.viewBGCell andHeight:[obj[@"height_cell"] floatValue]-15];
            if ([Common checkIphoneVersion:@"6"]) {
                [Common changeWidth:cell.viewBGCell andWidth:350];
            } else if([Common checkIphoneVersion:@"6P"]) {
                [Common changeWidth:cell.viewBGCell andWidth:385];
            } else {
                [Common changeWidth:cell.viewBGCell andWidth:295];
            }
            [Common changeX:cell.viewBGCell andX:5];
            [Common roundCornersOnView:cell.viewBGCell onTopLeft:YES topRight:YES bottomLeft:YES bottomRight:YES radius:5.0f];
            return cell;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_arrPlData count] > 0) {
        if (indexPath.row == [_arrPlData count]) {
            return 60;
        }
        
        NSDictionary *obj = [_arrPlData objectAtIndex:indexPath.row];
        float heightOfRow = 100;
        heightOfRow = HEIGHT_NAME_AREA_POST_LIST;
        heightOfRow += 70;
        if ([(NSArray *)obj[@"media"] count] > 0) {
            heightOfRow += HEIGHT_SLIDE_IMAGE_POST_LIST;
        }
        int widthConten = 270;
        if ([Common checkIphoneVersion:@"6"]) {
            widthConten = 320;
        }
        if ([Common checkIphoneVersion:@"6P"]) {
            widthConten = 360;
        }
        heightOfRow += [obj[@"height_content"] floatValue];
        
        NSMutableArray *arrCm = obj[@"comment"][@"items"];
        if ([arrCm count] > 0) {
            if ([obj[@"cm_expand"] isEqualToString:@"true"]) {
                heightOfRow += [self returnCommentsView:arrCm andLoadAll:true andFrom:@"post"].frame.size.height;
                heightOfRow += 20;
            } else{
                if ([obj[@"comment"][@"total"] integerValue] > 0) {
                    heightOfRow += [self returnCommentsView:arrCm andLoadAll:false andFrom:@"post"].frame.size.height;
                    heightOfRow += 20;
                }
            }
        } else {
            heightOfRow -= 15;
        }
        
        //Add height for space cell
        heightOfRow += 40;
        [_arrPlData objectAtIndex:indexPath.row][@"height_cell"] = @(heightOfRow);
        
        return heightOfRow;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if (indexPath.row ==  [_arrPlData count] - 1) {
        if (totalPage > [_arrPlData count]) {
            pageIndex++;
            [self callWSGetPostList:pageIndex andLimit:LIMIT_LIST_POST];
        }
    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.tblView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tblView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tblView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tblView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (IBAction)actionPostBack:(id)sender {
    if([delegate respondsToSelector:@selector(postListActionBack)])
    {
        [delegate postListActionBack];
    }
}

- (IBAction)actionHideKeyboard:(id)sender {
    [_composeBarView resignFirstResponder];
    _container.hidden = YES;
    if([delegate respondsToSelector:@selector(postListHideKeyboard)])
    {
        [delegate postListHideKeyboard];
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
