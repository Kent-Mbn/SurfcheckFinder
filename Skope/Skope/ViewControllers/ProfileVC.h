//
//  ProfileVC.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "profileCell.h"
#import "profilePostCell.h"
#import "ImportFiles.h"
#import "PHFComposeBarView.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "MWPhotoBrowser.h"
#import "ButtonShowImageSlide.h"
#import <MediaPlayer/MediaPlayer.h>

@protocol ProfileDelegate <NSObject>
- (void) profileActionBack;
- (void) profileHideKeyBoard;
- (void) profileShowKeyBoard;
@end

@interface ProfileVC : UIViewController<PHFComposeBarViewDelegate,UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MWPhotoBrowserDelegate> {
    NSDictionary *dicProfile;
    int selectedIndexPath;
    int addCommentAtIndex;
    int pageIndex;
    int totalPage;
    NSMutableArray *_selections;
}
@property (weak, nonatomic) IBOutlet UITableView *tblViewProfile;
@property(nonatomic,assign)id<ProfileDelegate> delegate;
@property (nonatomic, strong) NSDictionary *dicProfile;
@property(nonatomic, strong) PHFComposeBarView *composeBarView;
@property(nonatomic, strong) UIView *container;

@property (nonatomic, strong) NSMutableArray *arrPfContentsPost;
@property (nonatomic, strong) NSMutableArray *arrPfCommentsEachPost;
@property (weak, nonatomic) IBOutlet UIButton *btHideKeyboard;

@property (nonatomic, strong) NSMutableArray *arrPfData;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;
- (IBAction)actionHideKeyboard:(id)sender;

- (IBAction)actionBack:(id)sender;

@end
