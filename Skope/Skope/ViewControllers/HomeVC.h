//
//  HomeVC.h
//  Skope
//
//  Created by CHAU HUYNH on 2/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UICircularSlider.h"
#import "usersCell.h"
#import "postsCell.h"
#import "ImportFiles.h"
#import "viewCmProfile.h"
#import "PHFComposeBarView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <Quickblox/Quickblox.h>

@protocol HomeListDelegate <NSObject>
- (void) homeListActionShowUser;
- (void) homeListActionShowPost;
- (void) homeShowKeyBoard;
- (void) homeHideKeyBoard;
- (void) homeHideScreen:(float)regionMap;
- (void) homePostDone:(BOOL)isReload;

@end

@interface HomeVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,PHFComposeBarViewDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate, MKMapViewDelegate, UIActionSheetDelegate,QBChatDelegate> {
    int selectedIndexPath;
    int indexProcessComposePost;
    BOOL isMyProfile;
    float heightKeyboard;
    
    CLLocationManager *locationManager;
    CLLocationCoordinate2D userLocation;
    float radiusUpdate;
    
    id dataUserPost;
}

@property (nonatomic) NSTimer* timerUpdateUserLocation;
@property (nonatomic, strong) UIView *viewCameraChoosing;

@property(nonatomic,assign)id<HomeListDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btGoMyProfile;

@property (weak, nonatomic) IBOutlet UIView *viewRadiusMap;
@property (nonatomic, strong) NSMutableArray *arrDummyContents;
@property (nonatomic, strong) NSMutableArray *arrDummyComments;
@property (nonatomic, strong) NSMutableArray *arr_data_media;
@property (nonatomic, strong) NSMutableArray *arr_data_media_temp;

@property (weak, nonatomic) IBOutlet UICircularSlider *circular_slider;
@property (weak, nonatomic) IBOutlet UIView *viewHomeRight;
@property (weak, nonatomic) IBOutlet UIView *viewHomeLeft;
@property (weak, nonatomic) IBOutlet UIView *viewUsersDetail;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatarUsersDetail;
@property (weak, nonatomic) IBOutlet UIScrollView *scrUsersDetail;
@property (weak, nonatomic) IBOutlet UITableView *tblPosted;
@property (weak, nonatomic) IBOutlet UITableView *tblUsers;
@property (weak, nonatomic) IBOutlet MKMapView *mapV;
@property (weak, nonatomic) IBOutlet UIScrollView *scrDashboard;
@property (weak, nonatomic) IBOutlet UITextField *txtTest;
@property (weak, nonatomic) IBOutlet UITextField *txtCompose;
@property (weak, nonatomic) IBOutlet UIView *viewCompose;
@property (weak, nonatomic) IBOutlet UIButton *btChangePicture;
@property (weak, nonatomic) IBOutlet UILabel *lblNamePf;
@property (weak, nonatomic) IBOutlet UIButton *btEditName;
@property (weak, nonatomic) IBOutlet UIButton *btSendMess;
@property (weak, nonatomic) IBOutlet UILabel *lblPostOf;
@property (weak, nonatomic) IBOutlet UIView *viewCommentsPf;
@property (weak, nonatomic) IBOutlet UIView *viewEditMyProfile;

@property(nonatomic, strong) PHFComposeBarView *composeBarView;
@property(nonatomic, strong) UIView *container;
@property(nonatomic, strong) UIView *viewComposePhoto;
@property(nonatomic, strong) UIScrollView *scrCompose;
@property (weak, nonatomic) IBOutlet UILabel *lblMyPosts;
@property (weak, nonatomic) IBOutlet UILabel *lblPostsExtend;
@property (weak, nonatomic) IBOutlet UIButton *btHelpScreen;
@property (weak, nonatomic) IBOutlet UILabel *lblRadiusMap;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberUsers;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberPosts;
@property (weak, nonatomic) IBOutlet UIView *viewTakeOrChooseExisting;
@property (weak, nonatomic) IBOutlet UIButton *btHideCompose;


- (IBAction)actionGoUsersView:(id)sender;
- (IBAction)actionGoPostsView:(id)sender;
- (IBAction)actionBackFromUsersView:(id)sender;
- (IBAction)actionBackFromPostsView:(id)sender;
- (IBAction)actionBackFromUsersDetail:(id)sender;
- (IBAction)goProfile:(id)sender;
- (IBAction)actionCompose:(id)sender;
- (IBAction)actionHideHelp:(id)sender;
- (IBAction)actionTakePhotoVideo:(id)sender;
- (IBAction)actionChooseExisting:(id)sender;
- (IBAction)actionCancelTakePhoto:(id)sender;
- (IBAction)actionHideCompose:(id)sender;
- (IBAction)actionShowMessageList:(id)sender;


@end
