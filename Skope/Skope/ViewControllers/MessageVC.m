//
//  MessageVC.m
//  Skope
//
//  Created by Huynh Phong Chau on 3/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "MessageVC.h"
#import "PageContainVC.h"
#import <Parse/Parse.h>

#import "Define.h"
#import "messages.h"
#import "utilities.h"
#import <MediaPlayer/MediaPlayer.h>
#import "camera.h"
#import "pushnotification.h"
#import "JSQMessages.h"


static NSString *CellIdentifierMss = @"cellIdentifier";
CGRect const kInitialViewFrameMss = { 0.0f, 0.0f, 320.0f, 480.0f };

#define FONT_TEXT_MSS [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]
#define bgColorViewMssFromMe [UIColor colorWithRed: 23.0/255.0 green: 172.0/255.0 blue: 227.0/255.0 alpha: 1.0]
#define bgColorViewMssFromAnother [UIColor colorWithRed: 157.0/255.0 green: 206.0/255.0 blue: 48.0/255.0 alpha: 1.0]

#define sizeImageAvatarMss 80.0f
#define paddingTextMss 20.0f
#define heightViewTimeMss 40.0f

@interface MessageVC ()
{
    NSTimer *timer;
    BOOL isLoading;
    BOOL initialized;
        
    NSMutableArray *users;
    NSMutableArray *messages;
    NSMutableDictionary *avatars;
}
@end

@implementation MessageVC

@synthesize delegate;
@synthesize composeBarView = _composeBarView;
@synthesize container = _container;

- (void)viewDidLoad {
    [super viewDidLoad];

    _arrMssData = [[NSMutableArray alloc] initWithObjects: nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggleMss:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggleMss:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    _container = [self container];
    [_container addSubview:_btBack];
    [_container addSubview:_tblMessage];
    [_container addSubview:[self composeBarView]];
    [self.view addSubview:_container];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    _groupId = [defaults valueForKey:[NSString stringWithFormat:@"chat-%@",_emailUser]];
    NSLog(@"_groupId %@",_groupId);
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    users = [[NSMutableArray alloc] init];
    messages = [[NSMutableArray alloc] init];
    avatars = [[NSMutableDictionary alloc] init];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFUser *user = [PFUser currentUser];
    self.senderId = user.objectId;
    self.senderDisplayName = user[PF_USER_FULLNAME];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    isLoading = NO;
    initialized = NO;
    [self loadMessages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewWillDisappear:animated];
    ClearMessageCounter(_groupId);
    [timer invalidate];
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (isLoading == NO)
    {
        isLoading = YES;
        JSQMessage *message_last = [messages lastObject];
        
        PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
        [query whereKey:PF_CHAT_GROUPID equalTo:_groupId];
        if (message_last != nil) [query whereKey:PF_CHAT_CREATEDAT greaterThan:message_last.date];
        [query includeKey:PF_CHAT_USER];
        [query orderByDescending:PF_CHAT_CREATEDAT];
        [query setLimit:50];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 NSLog(@"%@",objects);
                 BOOL incoming = NO;
                 for (PFObject *object in [objects reverseObjectEnumerator])
                 {
                     JSQMessage *message = [self addMessage:object];
                     if ([self incoming:message]) incoming = YES;
                 }
                 if ([objects count] != 0)
                 {
                     if (initialized && incoming)
                         [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                     [self finishReceivingMessage];
                 }
                 initialized = YES;
             }
             else NSLog(@"Network error.");
             isLoading = NO;
         }];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)addMessage:(PFObject *)object
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    JSQMessage *message;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFUser *user = object[PF_CHAT_USER];
    NSString *name = user[PF_USER_FULLNAME];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFFile *fileVideo = object[PF_CHAT_VIDEO];
    PFFile *filePicture = object[PF_CHAT_PICTURE];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ((filePicture == nil) && (fileVideo == nil))
    {
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt text:object[PF_CHAT_TEXT]];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (fileVideo != nil)
    {
        JSQVideoMediaItem *mediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:fileVideo.url] isReadyToPlay:YES];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (filePicture != nil)
    {
        JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
        //-----------------------------------------------------------------------------------------------------------------------------------------
        [filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 mediaItem.image = [UIImage imageWithData:imageData];
             }
         }];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [users addObject:user];
    [messages addObject:message];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    return message;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFFile *fileVideo = nil;
    PFFile *filePicture = nil;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (video != nil)
    {
        text = @"[Video message]";
        fileVideo = [PFFile fileWithName:@"video.mp4" data:[[NSFileManager defaultManager] contentsAtPath:video.path]];
        [fileVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) NSLog(@"Network error.");
         }];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (picture != nil)
    {
        text = @"[Picture message]";
        filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) NSLog(@"Picture save error.");
         }];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
    object[PF_CHAT_USER] = [PFUser currentUser];
    object[PF_CHAT_GROUPID] = _groupId;
    object[PF_CHAT_TEXT] = text;
    if (fileVideo != nil) object[PF_CHAT_VIDEO] = fileVideo;
    if (filePicture != nil) object[PF_CHAT_PICTURE] = filePicture;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             [JSQSystemSoundPlayer jsq_playMessageSentSound];
             [self loadMessages];
         }
         else NSLog(@"Network error.");
     }];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    SendPushNotification(_groupId, text);
    UpdateMessageCounter(_groupId, text);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [self finishSendingMessage];
}

- (void)finishSendingMessage
{
    [self finishSendingMessageAnimated:YES];
}

- (void)finishSendingMessageAnimated:(BOOL)animated {
    
    
}

- (void)finishReceivingMessage
{
    [self finishReceivingMessageAnimated:YES];
}

- (void)finishReceivingMessageAnimated:(BOOL)animated {
    [_tblMessage reloadData];
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
- (void) setLayoutCellChatFromMe:(ChatCellFromMe *)cell andIndexPath:(NSIndexPath *)indexPath {
    NSString *txtChat = [messages objectAtIndex:indexPath.row][@"text"];
    
    NSString *strIsHaveImage = @"false";
    
    float widthChatTextArea = [Common widthScreen] - sizeImageAvatarMss - 40;
    float heightViewChatText = [Common getHeightOfText:widthChatTextArea - (paddingTextMss * 2) andText:txtChat andFont:FONT_TEXT_MSS] + (paddingTextMss * 2);
    cell.viewChatText.backgroundColor = bgColorViewMssFromMe;
    [Common changeWidthHeight:cell.imgAvatar andWidth:sizeImageAvatarMss andHeight:sizeImageAvatarMss];
    [Common circleImageView:cell.imgAvatar];
    
    [Common changeWidth:cell.viewChatText andWidth:widthChatTextArea];
    [cell.lblChatText setFont:FONT_TEXT_MSS];
    [Common changeHeight:cell.viewChatText andHeight:heightViewChatText];
    
    float yViewChatTime = heightViewChatText + 5;
    if ([strIsHaveImage isEqualToString:@"true"]) {
        [Common changeWidth:cell.viewImageChat andWidth:[Common widthScreen] - sizeImageAvatarMss - 40];
        [Common changeY:cell.viewImageChat andY:cell.viewChatText.frame.size.height];
        [Common changeHeight:cell.viewImageChat andHeight:(widthChatTextArea * 0.5)];
        yViewChatTime += (widthChatTextArea * 0.5);
        [Common changeY:cell.viewChatTimeName andY:yViewChatTime];
    } else {
        [Common changeY:cell.viewChatTimeName andY:yViewChatTime + 10];
    }
    [Common changeWidth:cell.viewChatTimeName andWidth:[Common widthScreen] - 30];
    
    
    [Common changeX:cell.lblChatName andX:[Common widthScreen] - 220];
    
    
    [Common roundCornersOnView:cell.viewChatText onTopLeft:false topRight:true bottomLeft:true bottomRight:true radius:5.0];
    [Common roundCornersOnView:cell.viewImageChat onTopLeft:false topRight:false bottomLeft:true bottomRight:true radius:5.0];
}

- (void) setLayoutCellChatFromAnother:(ChatCellFromAnother *)cell andIndexPath:(NSIndexPath *)indexPath {
    NSString *txtChat = [messages objectAtIndex:indexPath.row][@"text"];
    float widthChatTextArea = [Common widthScreen] - sizeImageAvatarMss - 30;
    [Common changeWidth:cell.viewChatTimeName andWidth:[Common widthScreen] - 30];
    
    [Common changeX:cell.imgAvatar andX:[Common widthScreen] - sizeImageAvatarMss - 10];
    
    [Common changeWidth:cell.viewChatText andWidth:widthChatTextArea];
    [cell.lblChatText setFont:FONT_TEXT_MSS];
    cell.viewChatText.backgroundColor = bgColorViewMssFromAnother;
    
    float heightViewChatText = [Common getHeightOfText:widthChatTextArea - (paddingTextMss * 2) andText:txtChat andFont:FONT_TEXT_MSS] + (paddingTextMss * 2);
    [Common changeHeight:cell.viewChatText andHeight:heightViewChatText];
    [Common changeY:cell.viewChatTimeName andY:0];
    if (heightViewChatText < sizeImageAvatarMss) {
        [Common changeY:cell.imgAvatar andY:10];
        [Common changeY:cell.viewChatText andY:sizeImageAvatarMss - heightViewChatText + 10];
    } else {
        [Common changeY:cell.viewChatText andY:heightViewTimeMss];
        [Common changeY:cell.imgAvatar andY:heightViewTimeMss + heightViewChatText - sizeImageAvatarMss];
    }
    float xTriangleChat = cell.viewChatText.frame.origin.x + cell.viewChatText.frame.size.width;
    float yTriangleChat = cell.viewChatText.frame.origin.y + cell.viewChatText.frame.size.height - 13;
    [Common changeXY:cell.imgTriangleChat andX:xTriangleChat andY:yTriangleChat];
    
    [Common roundCornersOnView:cell.viewChatText onTopLeft:true topRight:true bottomLeft:true bottomRight:false radius:5.0];
    [Common circleImageView:cell.imgAvatar];
}

- (float) heightForCell:(NSIndexPath *) indexPath {
    PFUser *user = [PFUser currentUser];
    PFUser *rowUser = [users objectAtIndex:indexPath.row];
    NSString *txtChat = [messages objectAtIndex:indexPath.row][@"text"];
    NSString *strIsHaveImage = false;
    NSString *strFromMe = (user.objectId == rowUser.objectId)?@"true":@"false" ;
    
    float widthChatTextArea = [Common widthScreen] - sizeImageAvatarMss - 40;
    if ([strFromMe isEqualToString:@"false"]) {
        widthChatTextArea = [Common widthScreen] - sizeImageAvatarMss - 30;
    }
    float heightViewChatText = [Common getHeightOfText:widthChatTextArea - (paddingTextMss * 2) andText:txtChat andFont:FONT_TEXT_MSS] + (paddingTextMss * 2);
    if (heightViewChatText < sizeImageAvatarMss) {
        heightViewChatText = sizeImageAvatarMss;
    }
    
    float heightImage = 0;
    if ([strIsHaveImage isEqualToString:@"true"]) {
        heightImage = widthChatTextArea * 0.5;
    }
    
    return heightViewChatText + heightImage + heightViewTimeMss;
}


#pragma mark - TABLE DELEGATE
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *user = [PFUser currentUser];
    PFUser *rowUser = [users objectAtIndex:indexPath.row];
    NSString *txtChat = [messages objectAtIndex:indexPath.row][@"text"];
    NSString *strIsHaveImage = false;
    NSString *strFromMe = (user.objectId == rowUser.objectId)?@"true":@"false" ;
    
    if ([strFromMe isEqualToString:@"true"]) {
        ChatCellFromMe *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdChatFromMe" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ChatCellFromMe class]) owner:nil options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([strIsHaveImage isEqualToString:@"false"]) {
            cell.viewImageChat.hidden = YES;
        }
        cell.lblChatText.text = txtChat;
        [self setLayoutCellChatFromMe:cell andIndexPath:indexPath];
        return cell;
    } else {
        ChatCellFromAnother *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdChatFromAnother" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ChatCellFromAnother class]) owner:nil options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.lblChatText.text = txtChat;
        [self setLayoutCellChatFromAnother:cell andIndexPath:indexPath];
        return cell;
    }
    
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForCell:indexPath];
}

#pragma mark - SEND MESSAGE INPUT
- (void)keyboardWillToggleMss:(NSNotification *)notification {
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
    
    //    [_arrChatData addObject:@{@"text":composeBarView.text, @"have_image":@"false",@"from_me":@"true"}];
    //    [_tblChat reloadData];
    [self sendMessage:composeBarView.text Video:nil Picture:nil];
    [composeBarView setText:@"" animated:YES];
    [composeBarView resignFirstResponder];
    
}

- (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView {
    if (![self startCameraControllerFromViewController:self usingDelegate:self]) {
        NSLog(@"Failed!");
    }
    
}


- (void)composeBarView:(PHFComposeBarView *)composeBarView
   willChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
              duration:(NSTimeInterval)duration
        animationCurve:(UIViewAnimationCurve)animationCurve
{
    NSLog(@"willChangeFromFrame");
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
{
    NSLog(@"didChangeFromFrame");
}


//@synthesize container = _container;
- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [Common widthScreen], [Common heightScreen])];
        [_container setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        _container.backgroundColor = [UIColor clearColor];
    }
    
    return _container;
}


- (PHFComposeBarView *) composeBarView {
    if (!_composeBarView) {
        CGRect frame = CGRectMake(0.0f,
                                  [Common heightScreen] - PHFComposeBarViewInitialHeight,
                                  [Common widthScreen],
                                  PHFComposeBarViewInitialHeight);
        _composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
        _composeBarView.buttonTintColor = COLOR_BUTTON_POST_SEND;
        [_composeBarView.textView setFont:FONT_TEXT_POST];
        [_composeBarView setMaxCharCount:160];
        [_composeBarView setMaxLinesCount:5];
        [_composeBarView setPlaceholder:@"Type something..."];
        [_composeBarView setUtilityButtonImage:[UIImage imageNamed:@"Camera"]];
        [_composeBarView.button setTitleColor:COLOR_BUTTON_POST_SEND forState:UIControlStateDisabled];
        _composeBarView.maxCharCount = 0;
        [_composeBarView setDelegate:self];
    }
    
    return _composeBarView;
}

#pragma mark - CAMERA DELEGATE
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    //[controller presentModalViewController: cameraUI animated: YES];
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [picker dismissViewControllerAnimated:YES completion:^(void) {
        
    }];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
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
        
    }
    
    // Handle a movie capture
    //    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
    //        == kCFCompareEqualTo) {
    //
    //        NSString *moviePath = [[info objectForKey:
    //                                UIImagePickerControllerMediaURL] path];
    //
    //        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
    //            UISaveVideoAtPathToSavedPhotosAlbum (
    //                                                 moviePath, nil, nil, nil);
    //        }
    //    }
    
    [picker dismissViewControllerAnimated:YES completion:^(void) {
        
    }];
    
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)incoming:(JSQMessage *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return ([message.senderId isEqualToString:self.senderId] == NO);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)outgoing:(JSQMessage *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return ([message.senderId isEqualToString:self.senderId] == YES);
}


#pragma mark - ACTION
- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
