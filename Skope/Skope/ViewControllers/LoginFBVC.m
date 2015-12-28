//
//  LoginFBVC.m
//  Skope
//
//  Created by Huynh Phong Chau on 2/28/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "LoginFBVC.h"
#import <Quickblox/Quickblox.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#include "Define.h"
#import "images.h"
#import "pushnotification.h"

@interface LoginFBVC ()

@end

@implementation LoginFBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UserDefault user] logoutUser];
    self.navigationController.navigationBar.hidden = YES;
    [AuthenFacebook authenFB].delegateAuthenFB = self;
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

- (void) saveUserAndRedirect:(id) jsonReturn {
    NSDictionary *data = jsonReturn[@"data"];
    NSDictionary *accessToken = data[@"accessToken"];
    NSDictionary *user = data[@"user"];
    if (accessToken[@"token"]) {
        [[UserDefault user] setToken:accessToken[@"token"]];
    }
    NSLog(@"saveUserAndRedirect");
    if (user) {
        [[UserDefault user] setUser:user];
        
        // Store the data
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setValue:data[@"ejabberd"][@"username"] forKey:@"chatID"];
        [defaults setValue:data[@"ejabberd"][@"password"] forKey:@"chatPassword"];
        [defaults setValue:data[@"user"][@"id"] forKey:@"loginQuickbloxID"];
        [defaults setValue:QUICKBLOX_PASSWORD forKey:@"passwordQuickblox"];
        [defaults synchronize];
        
//        QBUUser *quser = [QBUUser user];
//        quser.password = QUICKBLOX_PASSWORD;
//        quser.login = data[@"user"][@"id"];
//        
//        // Registration/sign up of User
//        [QBRequest signUp:quser successBlock:^(QBResponse *response, QBUUser *rquser) {
//            NSLog(@"successBlock %@",rquser);
//        } errorBlock:^(QBResponse *response) {
//            NSLog(@"errorBlock %@",response);
//        }];

    }
    
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
     {
         if (user != nil)
         {
             if (user[PF_USER_FACEBOOKID] == nil)
             {
                 [self requestFacebook:user];
             }
             else [self userLoggedIn:user];
         }
         else NSLog(@"%@",error.userInfo[@"error"]);
     }];

    
    //Redirect
    [APP_DELEGATE setRootViewLoginWithCompletion:^{
        
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)requestFacebook:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if (error == nil)
         {
             NSDictionary *userData = (NSDictionary *)result;
             [self processFacebook:user UserData:userData];
         }
         else
         {
             [PFUser logOut];
             NSLog(@"Failed to fetch Facebook user data.");
         }
     }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSString *link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         UIImage *image = (UIImage *)responseObject;
         //-----------------------------------------------------------------------------------------------------------------------------------------
         UIImage *picture = ResizeImage(image, 280, 280);
         UIImage *thumbnail = ResizeImage(image, 60, 60);
         //-----------------------------------------------------------------------------------------------------------------------------------------
         PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
         [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) NSLog(@"Network error.");
          }];
         //-----------------------------------------------------------------------------------------------------------------------------------------
         PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
         [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) NSLog(@"Network error.");
          }];
         //-----------------------------------------------------------------------------------------------------------------------------------------
         user[PF_USER_EMAILCOPY] = userData[@"email"];
         user[PF_USER_FULLNAME] = userData[@"name"];
         user[PF_USER_FULLNAME_LOWER] = [userData[@"name"] lowercaseString];
         user[PF_USER_FACEBOOKID] = userData[@"id"];
         user[PF_USER_PICTURE] = filePicture;
         user[PF_USER_THUMBNAIL] = fileThumbnail;
         [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error == nil)
              {
                  [self userLoggedIn:user];
              }
              else
              {
                  [PFUser logOut];
                  NSLog(@"%@",error.userInfo[@"error"]);
              }
          }];
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [PFUser logOut];
         NSLog(@"Failed to fetch Facebook profile picture.");
     }];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [[NSOperationQueue mainQueue] addOperation:operation];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)userLoggedIn:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    ParsePushUserAssign();
    NSLog(@"Welcome back %@!", user[PF_USER_FULLNAME]);
//    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)actionLoginFB:(id)sender {
    [Common showLoadingViewGlobal:nil];
    [[AuthenFacebook authenFB] beginAuthenFB];
}

- (void) submitLoginFacebook:(NSDictionary *) dicParamProfileFB andTokenFB:(NSString *)strTokenFB {
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSMutableDictionary *request_param = [@{
                                            @"fb_token":strTokenFB,
                                            } mutableCopy];
    NSLog(@"request_param: %@ %@", request_param, URL_SERVER_API(API_USER_LOGIN));
    [manager POST:URL_SERVER_API(API_USER_LOGIN) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideLoadingViewGlobal];
        NSLog(@"response LOGIN: %@", responseObject);
        if ([Common validateRespone:responseObject]) {
            [self saveUserAndRedirect:responseObject];
        } else {
            [Common showAlertView:APP_NAME message:MSS_LOGIN_TRY_AGAIN delegate:self cancelButtonTitle:TITLE_CANCEL_BT_ALERT arrayTitleOtherButtons:nil tag:0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideLoadingViewGlobal];
        [Common showAlertView:APP_NAME message:MSS_LOGIN_TRY_AGAIN delegate:self cancelButtonTitle:TITLE_CANCEL_BT_ALERT arrayTitleOtherButtons:nil tag:0];
    }];

}


#pragma mark - AUTHEN FACEBOOK DELEGATE
- (void) authenFacebookSuccess: (id)respone {
    [self submitLoginFacebook:respone andTokenFB:[AuthenFacebook accessTokenFB]];
}

- (void) authenFacebookFail: (id)error {
    [Common hideLoadingViewGlobal];
    [Common showAlertView:APP_NAME message:MSS_LOGIN_TRY_AGAIN delegate:self cancelButtonTitle:TITLE_CANCEL_BT_ALERT arrayTitleOtherButtons:nil tag:0];
}

@end
