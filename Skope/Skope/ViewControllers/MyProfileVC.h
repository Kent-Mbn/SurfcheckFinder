//
//  MyProfileVC.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myProfileCell.h"
#import "myProfilePostCell.h"
#import "ImportFiles.h"
#import "PHFComposeBarView.h"
#import "NSDate+TimeAgo.h"
#import "TTTAttributedLabel.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "MWPhotoBrowser.h"
#import "ButtonShowImageSlide.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MyProfileVC : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate, MWPhotoBrowserDelegate> {
    NSDictionary *dicProfile;
    int selectedIndexPath;
    int addCommentAtIndex;
    int pageIndex;
    int totalPage;
    NSIndexPath *indexPathNameAvatar;
    NSString *strNameTemp;
    NSMutableArray *_selections;
}
@property (weak, nonatomic) IBOutlet UITableView *tblMyProfile;

@property (nonatomic, strong) NSMutableArray *arrDummyComments;

@property (nonatomic, strong) NSDictionary *dicProfile;
@property(nonatomic, strong) PHFComposeBarView *composeBarView;
@property(nonatomic, strong) UIView *container;

@property (nonatomic, strong) NSMutableArray *arrPfContentsPost;
@property (nonatomic, strong) NSMutableArray *arrPfCommentsEachPost;
@property (weak, nonatomic) IBOutlet UIButton *btHideKeyboard;

@property (nonatomic, strong) NSMutableArray *arrPfData;
@property (weak, nonatomic) IBOutlet UIButton *btHideKeyBoard;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;

- (IBAction)actionHideKeyBoard:(id)sender;

- (IBAction)actionBack:(id)sender;
- (IBAction)actionHideKeyboard:(id)sender;

@end
