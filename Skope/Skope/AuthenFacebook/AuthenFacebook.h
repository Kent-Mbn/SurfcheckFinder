//
//  AuthenFacebook.h
//  Vidality
//
//  Created by CHAU HUYNH on 10/14/14.
//  Copyright (c) 2014 CHAU HUYNH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImportFiles.h"
#import <FacebookSDK/FacebookSDK.h>

#pragma mark - AUTHEN FACEBOOK DELEGATE
@protocol AuthenFacebookDelegate <NSObject>
@required
- (void) authenFacebookSuccess: (id)respone;
- (void) authenFacebookFail: (id)error;
@end

@interface AuthenFacebook : NSObject

@property (nonatomic, weak) id <AuthenFacebookDelegate> delegateAuthenFB;

+ (AuthenFacebook *) authenFB;
- (void) beginAuthenFB;
+ (BOOL) isSeesionFBOpen;
+ (void) clearSessionFB;
+ (NSString *) accessTokenFB;

@end
