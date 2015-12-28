//
//  ChatVC.m
//  Skope
//
//  Created by CHAU HUYNH on 2/14/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "ChatVC.h"

static NSString *CellIdentifier = @"cellIdentifier";
CGRect const kInitialViewFrameChat = { 0.0f, 0.0f, 320.0f, 480.0f };

#define FONT_TEXT_CHAT [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]
#define bgColorViewChatFromMe [UIColor colorWithRed: 23.0/255.0 green: 172.0/255.0 blue: 227.0/255.0 alpha: 1.0]
#define bgColorViewChatFromAnother [UIColor colorWithRed: 157.0/255.0 green: 206.0/255.0 blue: 48.0/255.0 alpha: 1.0]

#define sizeImageAvatar 80.0f
#define paddingTextChat 20.0f
#define heightViewTimeChat 40.0f

@interface ChatVC ()

@end

@implementation ChatVC

@synthesize composeBarView = _composeBarView;
@synthesize container = _container;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _arrChatData = [[NSMutableArray alloc] initWithObjects:@{@"text":@"Cute ah? kdjkfls skdjflksd jdsklfjksdl lskdjflksdj flksdjlfksjdlf sldkfjls kdjfl skdjf ", @"have_image":@"true",@"from_me":@"true"},@{@"text":@"Cute ah? aksjhdkjas kasjhdkjashd kajshdkajsh dkjahsdkjahs dkjahskdjahsd kajshdkajs ksdljkfj lskdjf sldkfjlskdjfs dlfksjd", @"have_image":@"false",@"from_me":@"false"},@{@"text":@"Cute ah? kdjkfls skdjflksd", @"have_image":@"false",@"from_me":@"true"},@{@"text":@"Cute ah? aksjhdkjas kasjhdkjashd kajshdkajsh dkjahsdkjahs dkjahskdjahsd kajshdkajs ksdljkfj lskdjf sldkfjlskdjfs dlfksjd", @"have_image":@"false",@"from_me":@"false"}, nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggleChat:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggleChat:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    _container = [self container];
    [_container addSubview:_btBack];
    [_container addSubview:_tblChat];
    [_container addSubview:[self composeBarView]];
    [self.view addSubview:_container];
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

#pragma mark - FUNCTIONS
- (void) setLayoutCellChatFromMe:(ChatCellFromMe *)cell andIndexPath:(NSIndexPath *)indexPath {
    NSString *txtChat = [_arrChatData objectAtIndex:indexPath.row][@"text"];
    
    NSString *strIsHaveImage = [_arrChatData objectAtIndex:indexPath.row][@"have_image"];
    
    float widthChatTextArea = [Common widthScreen] - sizeImageAvatar - 40;
    float heightViewChatText = [Common getHeightOfText:widthChatTextArea - (paddingTextChat * 2) andText:txtChat andFont:FONT_TEXT_CHAT] + (paddingTextChat * 2);
    cell.viewChatText.backgroundColor = bgColorViewChatFromMe;
    [Common changeWidthHeight:cell.imgAvatar andWidth:sizeImageAvatar andHeight:sizeImageAvatar];
    [Common circleImageView:cell.imgAvatar];
    
    [Common changeWidth:cell.viewChatText andWidth:widthChatTextArea];
    [cell.lblChatText setFont:FONT_TEXT_CHAT];
    [Common changeHeight:cell.viewChatText andHeight:heightViewChatText];
    
    float yViewChatTime = heightViewChatText + 5;
    if ([strIsHaveImage isEqualToString:@"true"]) {
        [Common changeWidth:cell.viewImageChat andWidth:[Common widthScreen] - sizeImageAvatar - 40];
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
    NSString *txtChat = [_arrChatData objectAtIndex:indexPath.row][@"text"];
    float widthChatTextArea = [Common widthScreen] - sizeImageAvatar - 30;
    [Common changeWidth:cell.viewChatTimeName andWidth:[Common widthScreen] - 30];
    
    [Common changeX:cell.imgAvatar andX:[Common widthScreen] - sizeImageAvatar - 10];
    
    [Common changeWidth:cell.viewChatText andWidth:widthChatTextArea];
    [cell.lblChatText setFont:FONT_TEXT_CHAT];
    cell.viewChatText.backgroundColor = bgColorViewChatFromAnother;
    
    float heightViewChatText = [Common getHeightOfText:widthChatTextArea - (paddingTextChat * 2) andText:txtChat andFont:FONT_TEXT_CHAT] + (paddingTextChat * 2);
    [Common changeHeight:cell.viewChatText andHeight:heightViewChatText];
    [Common changeY:cell.viewChatTimeName andY:0];
    if (heightViewChatText < sizeImageAvatar) {
        [Common changeY:cell.imgAvatar andY:10];
        [Common changeY:cell.viewChatText andY:sizeImageAvatar - heightViewChatText + 10];
    } else {
        [Common changeY:cell.viewChatText andY:heightViewTimeChat];
        [Common changeY:cell.imgAvatar andY:heightViewTimeChat + heightViewChatText - sizeImageAvatar];
    }
    float xTriangleChat = cell.viewChatText.frame.origin.x + cell.viewChatText.frame.size.width;
    float yTriangleChat = cell.viewChatText.frame.origin.y + cell.viewChatText.frame.size.height - 13;
    [Common changeXY:cell.imgTriangleChat andX:xTriangleChat andY:yTriangleChat];
    
    [Common roundCornersOnView:cell.viewChatText onTopLeft:true topRight:true bottomLeft:true bottomRight:false radius:5.0];
    [Common circleImageView:cell.imgAvatar];
}

- (float) heightForCell:(NSIndexPath *) indexPath {
    NSString *txtChat = [_arrChatData objectAtIndex:indexPath.row][@"text"];
    NSString *strIsHaveImage = [_arrChatData objectAtIndex:indexPath.row][@"have_image"];
    NSString *strFromMe = [_arrChatData objectAtIndex:indexPath.row][@"from_me"];
    
    float widthChatTextArea = [Common widthScreen] - sizeImageAvatar - 40;
    if ([strFromMe isEqualToString:@"false"]) {
        widthChatTextArea = [Common widthScreen] - sizeImageAvatar - 30;
    }
    float heightViewChatText = [Common getHeightOfText:widthChatTextArea - (paddingTextChat * 2) andText:txtChat andFont:FONT_TEXT_CHAT] + (paddingTextChat * 2);
    if (heightViewChatText < sizeImageAvatar) {
        heightViewChatText = sizeImageAvatar;
    }
    
    float heightImage = 0;
    if ([strIsHaveImage isEqualToString:@"true"]) {
        heightImage = widthChatTextArea * 0.5;
    }
    
    return heightViewChatText + heightImage + heightViewTimeChat;
}


#pragma mark - TABLE DELEGATE
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrChatData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *txtChat = [_arrChatData objectAtIndex:indexPath.row][@"text"];
    NSString *strIsHaveImage = [_arrChatData objectAtIndex:indexPath.row][@"have_image"];
    NSString *strFromMe = [_arrChatData objectAtIndex:indexPath.row][@"from_me"];
    
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
- (void)keyboardWillToggleChat:(NSNotification *)notification {
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



#pragma mark - ACTION
- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
