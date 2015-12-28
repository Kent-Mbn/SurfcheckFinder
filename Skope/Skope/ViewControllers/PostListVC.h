//
//  PostListVC.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/4/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "postsCell.h"
#import "Common.h"
#import "PHFComposeBarView.h"
#import "MWPhotoBrowser.h"
#import "ButtonShowImageSlide.h"
#import "NSDate+TimeAgo.h"
#import "TTTAttributedLabel.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@import MediaPlayer;

@protocol PostListDelegate <NSObject>
- (void) postListActionBack;
- (void) showPostListScreen;
- (void) postListShowKeyboard;
- (void) postListHideKeyboard;
@end

@interface PostListVC : UIViewController<PHFComposeBarViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MWPhotoBrowserDelegate> {
    NSDictionary *dicPostList;
    NSMutableArray *_selections;
    
    float regionMap;
    float regionMapTemp;
    int selectedIndexPath;
    int addCommentAtIndex;
    int pageIndex;
    int totalPage;
}

@property (nonatomic, assign) BOOL isReload;
@property (nonatomic, strong) NSMutableArray *arrDummyContents;
@property (nonatomic, strong) NSMutableArray *arrDummyComments;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property(nonatomic, strong) PHFComposeBarView *composeBarView;
@property(nonatomic, strong) UIView *container;
@property (nonatomic, strong) NSDictionary *dicPostList;
@property float regionMap;
@property (weak, nonatomic) IBOutlet UIButton *btHideKeyboard;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;

@property(nonatomic,assign)id<PostListDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *arrPlData;
- (IBAction)actionPostBack:(id)sender;
- (IBAction)actionHideKeyboard:(id)sender;

@end
