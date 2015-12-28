//
//  AuthenFacebook.m
//  Vidality
//
//  Created by CHAU HUYNH on 10/14/14.
//  Copyright (c) 2014 CHAU HUYNH. All rights reserved.
//

#import "AuthenFacebook.h"

@implementation AuthenFacebook
@synthesize delegateAuthenFB;

static AuthenFacebook *globalAuthenFB;

- (id) init {
    return self;
}

+ (AuthenFacebook *) authenFB
{
    if (!globalAuthenFB) {
        if (!globalAuthenFB) {
            globalAuthenFB = [[AuthenFacebook alloc] init];
        }
    }
    return globalAuthenFB;
}

- (void) beginAuthenFB {
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [self requesUserInfo];
    } else {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             [self sessionStateChanged:session state:state error:error];
         }];
    }
}

+ (void) clearSessionFB {
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
}

+ (BOOL) isSeesionFBOpen {
    return FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended;
}

+ (NSString *) accessTokenFB {
    if([self isSeesionFBOpen]) {
        return [[[FBSession activeSession] accessTokenData] accessToken];
    }
    return @"";
}

#pragma mark - FACEBOOK FUNCTIONS

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    if (!error && state == FBSessionStateOpen){
        [self requesUserInfo];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        NSLog(@"Session closed: %d", state);
    }
    
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
        } else {
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
            } else {
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
            }
        }
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

- (void) requesUserInfo {
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  [self makeRequestForUserData];
                              } else {
                                 
                                  if ([self.delegateAuthenFB respondsToSelector:@selector(authenFacebookFail:)]) {
                                      [self.delegateAuthenFB authenFacebookFail:error];
                                  }
                                  
                              }
                        
                          }];
}

- (void) makeRequestForUserData
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            if ([self.delegateAuthenFB respondsToSelector:@selector(authenFacebookSuccess:)]) {
                [self.delegateAuthenFB authenFacebookSuccess:result];
            }
            return;
        } else {
            if ([self.delegateAuthenFB respondsToSelector:@selector(authenFacebookFail:)]) {
                [self.delegateAuthenFB authenFacebookFail:error];
            }
            return;
        }
    }];
}



@end
